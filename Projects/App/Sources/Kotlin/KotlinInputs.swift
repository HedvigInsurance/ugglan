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
/// thread; lines reach the logger on the main queue in the order they were logged. Debug builds also write each line
/// to the unified log, since the app logger prints nothing to the console.
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
            let name = priority.name
            Self.console.log("\(name, privacy: .public) [\(tag ?? "", privacy: .public)] \(message, privacy: .public)")
        #endif
        let attributes: [AttributeKey: AttributeValue] = ["source": "kotlin", "tag": tag ?? ""]
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                level.write(message, attributes: attributes, to: hCore.log)
            }
        }
    }
}

enum KotlinLogLevel: Equatable {
    case debug, info, warn, error, critical

    init(_ priority: LogPriority) {
        switch priority {
        case .verbose, .debug: self = .debug
        case .info: self = .info
        case .warn: self = .warn
        case .error: self = .error
        default: self = .critical
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
