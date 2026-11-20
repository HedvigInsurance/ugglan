import Apollo
import Environment
import Foundation
@preconcurrency import HedvigShared
import hCore
import hGraphQL

/// The member's access token from the Keychain, refreshed first through `TokenRefresher`, the app's one refresh path.
/// Kotlin calls it before each member request, from any thread.
///
/// Behaves like `HeadersInterceptor`: nil only when the Keychain holds no token (logged out). When a token is stored but
/// cannot be produced now (the Keychain read or the refresh failed), it throws, so Kotlin does not send the request and
/// reports a network failure, which surfaces like an Octopus request that could not be sent.
final class KeychainAccessTokenFetcher: NSObject, AccessTokenFetcher, @unchecked Sendable {
    private let retrieveToken: @Sendable () async throws -> OAuthorizationToken?
    private let refreshIfNeeded: @Sendable () async throws -> Void

    init(
        retrieveToken: @escaping @Sendable () async throws -> OAuthorizationToken? = {
            try await ApolloClient.retreiveToken()
        },
        refreshIfNeeded: @escaping @Sendable () async throws -> Void = {
            try await TokenRefresher.shared.refreshIfNeeded()
        }
    ) {
        self.retrieveToken = retrieveToken
        self.refreshIfNeeded = refreshIfNeeded
    }

    func fetch() async throws -> String? {
        guard try await retrieveToken() != nil else { return nil }
        try await refreshIfNeeded()
        return try await retrieveToken()?.accessToken
    }
}

/// The device id Octopus requests send, kept in `UserDefaults`.
final class UserDefaultsDeviceIdFetcher: NSObject, DeviceIdFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        await ApolloClient.getDeviceIdentifier()
    }
}

/// The app's current locale. Kotlin calls it from any thread; the subject's value is safe to read off the main thread.
final class CurrentLocaleLanguageSource: NSObject, IosLanguageSource, @unchecked Sendable {
    func currentLanguage() -> Language {
        switch Localization.Locale.currentLocale.value {
        case .sv_SE: .svSe
        case .en_SE: .enSe
        }
    }
}

extension Environment {
    /// Picks the backend Kotlin talks to. A custom endpoint has no Kotlin flavor and gets staging.
    var flavor: Flavor {
        switch self {
        case .production: .production
        case .staging, .custom: .staging
        }
    }
}

extension NetworkLogPolicy {
    /// Staging logs HTTP bodies and GraphQL data. Production logs GraphQL error text only, like Octopus does, and never
    /// bodies, data, variables or tokens.
    convenience init(flavor: Flavor) {
        let logsMemberData = flavor != .production
        self.init(logsHttpBodies: logsMemberData, logsGraphqlData: logsMemberData, logsGraphqlErrors: true)
    }
}

extension LogPriority {
    /// The lowest Kotlin log priority that reaches `log`. Staging takes VERBOSE, where the HTTP bodies its
    /// `NetworkLogPolicy` allows are logged; production stops at INFO, the lowest level `DatadogLogger` keeps there.
    @MainActor static func minimumForKotlin(flavor: Flavor = Environment.current.flavor) -> LogPriority {
        flavor == .production ? .info : .verbose
    }
}
