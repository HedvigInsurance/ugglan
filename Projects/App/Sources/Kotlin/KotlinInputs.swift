import Apollo
import Foundation
@preconcurrency import HedvigShared
import Logger
import hCore
import hGraphQL
import os

/// Kotlin asks for the token before each member request, from any thread. The refresh goes through `TokenRefresher`,
/// the app's only refresh path, and the token stays in the Keychain. Nil when logged out.
final class KotlinAccessTokenFetcher: NSObject, AccessTokenFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        guard try await ApolloClient.retreiveToken() != nil else { return nil }
        try await TokenRefresher.shared.refreshIfNeeded()
        return try await ApolloClient.retreiveToken()?.accessToken
    }
}

final class KotlinDeviceIdFetcher: NSObject, DeviceIdFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        await ApolloClient.getDeviceIdentifier()
    }
}

/// Called from any thread; `currentLocale` is a subject whose value is safe to read off the main thread.
final class KotlinLanguageSource: NSObject, IosLanguageSource, @unchecked Sendable {
    func currentLanguage() -> Language {
        switch Localization.Locale.currentLocale.value {
        case .sv_SE: .svSe
        case .en_SE: .enSe
        }
    }
}

/// Forwards Kotlin's log lines to the app logger, which Release builds send to Datadog. Kotlin calls it from any
/// thread; lines reach `KotlinLogDestination` on the main queue in the order they were logged. Debug builds also write
/// each line to the unified log, since the app logger prints nothing to the console.
final class KotlinLogForwarder: NSObject, IosLogSink, @unchecked Sendable {
    static var minimumPriority: LogPriority {
        #if DEBUG
            .debug
        #else
            .warn
        #endif
    }

    #if DEBUG
        static let console = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "Ugglan", category: "Kotlin")
    #endif

    func log(priority: LogPriority, tag: String?, message: String) {
        let level = KotlinLogLevel(priority)
        #if DEBUG
            let label = level.label
            Self.console.log("\(label, privacy: .public) [\(tag ?? "", privacy: .public)] \(message, privacy: .public)")
        #endif
        let attributes: [AttributeKey: AttributeValue] = ["source": "kotlin", "tag": tag ?? ""]
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                KotlinLogDestination.shared.write(level, message, attributes: attributes)
            }
        }
    }
}

/// Where forwarded Kotlin lines go. The app logger becomes the Datadog logger only in `initialSetup`, after Kotlin may
/// already have logged, so lines are held here until `attach` and then written in order. Holds at most `capacity`
/// lines; beyond that the oldest are dropped and their count is logged on attach.
@MainActor
final class KotlinLogDestination {
    static let shared = KotlinLogDestination()

    struct Line {
        let level: KotlinLogLevel
        let message: String
        let attributes: [AttributeKey: AttributeValue]
    }

    let capacity: Int
    private var logger: (any Logging)?
    private(set) var pending: [Line] = []
    private var dropped = 0

    init(capacity: Int = 200) {
        self.capacity = capacity
    }

    func write(_ level: KotlinLogLevel, _ message: String, attributes: [AttributeKey: AttributeValue]) {
        if let logger {
            level.write(message, attributes: attributes, to: logger)
            return
        }
        if pending.count == capacity {
            pending.removeFirst()
            dropped += 1
        }
        pending.append(Line(level: level, message: message, attributes: attributes))
    }

    /// Sends every held line to `logger`, then sends each later line straight to it.
    func attach(_ logger: any Logging) {
        self.logger = logger
        if dropped > 0 {
            logger.warn(
                "Kotlin log lines dropped before the logger was ready",
                error: nil,
                attributes: ["source": "kotlin", "dropped": dropped]
            )
        }
        for line in pending {
            line.level.write(line.message, attributes: line.attributes, to: logger)
        }
        pending = []
        dropped = 0
    }
}

enum KotlinLogLevel: Equatable {
    case debug, info, warn, error, critical

    init(_ priority: LogPriority) {
        switch priority.nsEnum {
        case .verbose, .debug: self = .debug
        case .info: self = .info
        case .warn: self = .warn
        case .error: self = .error
        case .assert: self = .critical
        @unknown default: self = .error
        }
    }

    var label: String {
        switch self {
        case .debug: "DEBUG"
        case .info: "INFO"
        case .warn: "WARN"
        case .error: "ERROR"
        case .critical: "CRITICAL"
        }
    }

    func write(_ message: String, attributes: [AttributeKey: AttributeValue], to logger: any Logging) {
        switch self {
        case .debug: logger.debug(message, error: nil, attributes: attributes)
        case .info: logger.info(message, error: nil, attributes: attributes)
        case .warn: logger.warn(message, error: nil, attributes: attributes)
        case .error: logger.error(message, error: nil, attributes: attributes)
        case .critical: logger.critical(message, error: nil, attributes: attributes)
        }
    }
}
