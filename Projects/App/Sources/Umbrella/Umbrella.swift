import Apollo
import Environment
import Foundation
@preconcurrency import HedvigShared
import Logger
import hCore
import hGraphQL
import os

/// The shared Kotlin graph that Kotlin reads run in. It exists only while `UmbrellaSwitch` is on, and then at most
/// once per process: the holder is created by the first read that needs it, and Kotlin builds its graph on that same
/// first use.
@MainActor
enum Umbrella {
    /// Read once per process: turning the switch on or off takes a relaunch.
    static let isEnabled: Bool = UmbrellaSwitch.current.isOn

    private static var created: IosGraphHolder?

    /// The holder, created on first use, or nil while the switch is off.
    static var holder: IosGraphHolder? {
        guard isEnabled else { return nil }
        return existingOrNewHolder()
    }

    /// Kotlin allows one holder per process: a second `createIosGraphHolder` call crashes a debug framework.
    static func existingOrNewHolder() -> IosGraphHolder {
        if let created { return created }
        let holder = IosGraphHolderKt.createIosGraphHolder(
            appFlavor: UmbrellaAppFlavor.current,
            accessTokenFetcher: UmbrellaAccessTokenFetcher(),
            deviceIdFetcher: UmbrellaDeviceIdFetcher(),
            languageSource: UmbrellaLanguageSource(),
            networkLogPolicy: UmbrellaNetworkLogPolicy.current
        )
        created = holder
        note("created the graph holder")
        return holder
    }

    /// Called at launch, before anything in Kotlin can log. With the switch off Kotlin keeps writing to `NSLog`.
    static func installLogging() {
        guard isEnabled else {
            IosLogcatLogger.companion.install()
            return
        }
        IosLogcatLogger.companion.install(
            sink: UmbrellaLogForwarder(),
            minimumPriority: UmbrellaLogForwarder.minimumPriority
        )
        note("on, Kotlin logs go to the app logger")
    }

    /// Called once the app logger is the Datadog logger: writes the Kotlin lines held until now, then every later one.
    static func attachLogger(_ logger: any Logging) {
        UmbrellaLogDestination.shared.attach(logger)
    }

    private static func note(_ event: String) {
        log.info("Kotlin reads: \(event)")
        #if DEBUG
            UmbrellaLogForwarder.console.log("Kotlin reads: \(event, privacy: .public)")
        #endif
    }

    /// After a login stored the new token. A holder not created yet has no reads to end.
    static func sessionStarted() {
        guard let created else { return }
        created.sessionStarted()
        note("session started")
    }

    /// After the token was deleted at logout.
    static func sessionEnded() {
        guard let created else { return }
        created.sessionEnded()
        note("session ended")
    }
}

/// Whether Kotlin reads run at all. Off unless a Debug build is launched with `-kotlinReads`, or the remote flag turns
/// it on.
struct UmbrellaSwitch {
    static let launchArgument = "-kotlinReads"

    let launchArgumentIsOn: Bool
    let remoteFlagIsOn: Bool

    var isOn: Bool { launchArgumentIsOn || remoteFlagIsOn }

    @MainActor
    static var current: UmbrellaSwitch {
        #if DEBUG
            let launchArgumentIsOn = isOn(arguments: ProcessInfo.processInfo.arguments)
        #else
            let launchArgumentIsOn = false
        #endif
        return UmbrellaSwitch(launchArgumentIsOn: launchArgumentIsOn, remoteFlagIsOn: UmbrellaRemoteFlag.isOn)
    }

    /// `-kotlinReads` alone or followed by a value other than `NO`, `false` or `0`.
    static func isOn(arguments: [String]) -> Bool {
        guard let index = arguments.firstIndex(of: launchArgument) else { return false }
        let next = arguments.dropFirst(index + 1).first
        guard let value = next, !value.hasPrefix("-") else { return true }
        return !["no", "false", "0"].contains(value.lowercased())
    }
}

/// Where the remote flag for Kotlin reads will be read, from `FeatureFlagsClient`, once it exists. Until then it is off
/// in every build.
enum UmbrellaRemoteFlag {
    static var isOn: Bool { false }
}

/// The only build fact Swift gives Kotlin; it also picks the backend. A custom endpoint has no Kotlin flavor and gets
/// staging.
enum UmbrellaAppFlavor {
    @MainActor
    static var current: Flavor { flavor(for: Environment.current, isDebugBuild: isDebugBuild) }

    static func flavor(for environment: Environment, isDebugBuild: Bool) -> Flavor {
        switch environment {
        case .production: .production
        case .staging, .custom: isDebugBuild ? .develop : .staging
        }
    }

    static var isDebugBuild: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
}

/// Staging logs HTTP bodies and GraphQL data and errors. Production logs GraphQL error text only, never bodies, data,
/// variables or tokens; Kotlin also forces bodies and data off for a production flavor.
enum UmbrellaNetworkLogPolicy {
    @MainActor
    static var current: NetworkLogPolicy { policy(for: UmbrellaAppFlavor.current) }

    static func policy(for flavor: Flavor) -> NetworkLogPolicy {
        let logsMemberData = flavor != .production
        return NetworkLogPolicy(
            logsHttpBodies: logsMemberData,
            logsGraphqlData: logsMemberData,
            logsGraphqlErrors: true
        )
    }
}

/// Kotlin asks for the token before each member request, from any thread. The refresh goes through `TokenRefresher`,
/// the app's only refresh path, and the token stays in the Keychain. Nil when logged out.
final class UmbrellaAccessTokenFetcher: NSObject, AccessTokenFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        guard try await ApolloClient.retreiveToken() != nil else { return nil }
        try await TokenRefresher.shared.refreshIfNeeded()
        return try await ApolloClient.retreiveToken()?.accessToken
    }
}

final class UmbrellaDeviceIdFetcher: NSObject, DeviceIdFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        await ApolloClient.getDeviceIdentifier()
    }
}

/// Called from any thread; `currentLocale` is a subject whose value is safe to read off the main thread.
final class UmbrellaLanguageSource: NSObject, IosLanguageSource, @unchecked Sendable {
    func currentLanguage() -> Language {
        switch Localization.Locale.currentLocale.value {
        case .sv_SE: .svSe
        case .en_SE: .enSe
        }
    }
}
