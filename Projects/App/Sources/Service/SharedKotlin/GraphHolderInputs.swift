import Apollo
import Environment
import Foundation
@preconcurrency import HedvigShared
import hCore
import hGraphQL

/// The member's access token from the Keychain, refreshed first through `TokenRefresher`, the app's one refresh path.
/// Nil when logged out. Kotlin calls it before each member request, from any thread.
final class KeychainAccessTokenFetcher: NSObject, AccessTokenFetcher, @unchecked Sendable {
    func fetch() async throws -> String? {
        guard try await ApolloClient.retreiveToken() != nil else { return nil }
        try await TokenRefresher.shared.refreshIfNeeded()
        return try await ApolloClient.retreiveToken()?.accessToken
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
