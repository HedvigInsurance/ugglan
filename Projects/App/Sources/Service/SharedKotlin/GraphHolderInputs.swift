import Apollo
import Environment
import Foundation
@preconcurrency import HedvigShared
import hCore
import hGraphQL

/// Behaves like `HeadersInterceptor`: nil only when logged out, and throws when a stored token cannot be produced, so
/// Kotlin does not send the request.
final class KeychainAccessTokenFetcher: NSObject, AccessTokenFetcher, Sendable {
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

final class UserDefaultsDeviceIdFetcher: NSObject, DeviceIdFetcher, Sendable {
    func fetch() async throws -> String? {
        await ApolloClient.getDeviceIdentifier()
    }
}

/// Kotlin calls it from any thread; the subject's value is safe to read off the main thread.
final class CurrentLocaleLanguageSource: NSObject, IosLanguageSource, Sendable {
    func currentLanguage() -> Language {
        switch Localization.Locale.currentLocale.value {
        case .sv_SE: .svSe
        case .en_SE: .enSe
        }
    }
}

extension Environment {
    /// A custom endpoint has no Kotlin flavor and gets staging.
    var flavor: Flavor {
        switch self {
        case .production: .production
        case .staging, .custom: .staging
        }
    }
}

extension NetworkLogPolicy {
    /// Production logs GraphQL error text only, like Octopus, never bodies or data.
    convenience init(flavor: Flavor) {
        let logsMemberData = flavor != .production
        self.init(logsHttpBodies: logsMemberData, logsGraphqlData: logsMemberData, logsGraphqlErrors: true)
    }
}

extension LogPriority {
    /// Production stops at INFO, the lowest level `DatadogLogger` keeps there.
    @MainActor static func minimumForKotlin(flavor: Flavor = Environment.current.flavor) -> LogPriority {
        flavor == .production ? .info : .verbose
    }
}
