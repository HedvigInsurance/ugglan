import Apollo
import Foundation
import OdysseyKit
import hCore
import hGraphQL

extension TokenRefresher: AccessTokenProvider {
    public func provide() async -> String? {
        await withCheckedContinuation { continuation in
            refreshIfNeeded().onValue { _ in
                continuation.resume(returning: ApolloClient.retreiveToken()?.accessToken)
            }
        }
    }
}

extension AppDelegate {
    func initOdyssey() {
        OdysseyKit.initialize(
            apiUrl: Environment.current.odysseyApiURL.absoluteString,
            accessTokenProvider: TokenRefresher.shared,
            locale: Localization.Locale.currentLocale.acceptLanguageHeader,
            enableNetworkLogs: true
        )
    }
}
