import Flow
import Foundation
import hCore
import UIKit

extension ApplicationState {
    private static let firebaseMessagingTokenKey = "firebaseMessagingToken"

    static func setFirebaseMessagingToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ApplicationState.firebaseMessagingTokenKey)
    }

    static func getFirebaseMessagingToken() -> String? {
        UserDefaults.standard.value(forKey: firebaseMessagingTokenKey) as? String
    }

    public static let lastNewsSeenKey = "lastNewsSeen"

    static func getLastNewsSeen() -> String {
        UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
    }

    static func setLastNewsSeen() {
        UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }

    static func getTargetEnvironment() -> Environment {
        guard
            let targetEnvirontmentRawValue = UserDefaults.standard.value(forKey: targetEnvironmentKey) as? String,
            let targetEnvironment = Environment(rawValue: targetEnvirontmentRawValue) else {
            #if APP_VARIANT_PRODUCTION
                return .production
            #elseif APP_VARIANT_STAGING
                return .staging
            #else
                return .production
            #endif
        }
        return targetEnvironment
    }

    static func presentRootViewController(_ window: UIWindow) -> Disposable {
        guard let applicationState = currentState
        else {
            return window.present(
                MarketPicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        }

        switch applicationState {
        case .marketPicker:
            return window.present(
                MarketPicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .languagePicker:
            return window.present(
                PreMarketingLanguagePicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .marketing:
            return window.present(
                Marketing(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .onboardingChat, .onboarding:
            return window.present(Onboarding(), options: [.defaults], animated: false)
        case .offer:
            return window.present(
                Offer(),
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)],
                animated: false
            )
        case .loggedIn:
            return window.present(
                LoggedIn(),
                options: [],
                animated: false
            )
        }
    }
}

extension ApplicationState.Environment {
    var apolloEnvironmentConfig: ApolloEnvironmentConfig {
        switch getTargetEnvironment() {
        case .staging:
            return ApolloEnvironmentConfig(
                endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
                wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
                assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
            )
        case .production:
            return ApolloEnvironmentConfig(
                endpointURL: URL(string: "https://giraffe.hedvig.com/graphql")!,
                wsEndpointURL: URL(string: "wss://giraffe.hedvig.com/subscriptions")!,
                assetsEndpointURL: URL(string: "https://giraffe.hedvig.com")!
            )
        case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
            return ApolloEnvironmentConfig(
                endpointURL: endpointURL,
                wsEndpointURL: wsEndpointURL,
                assetsEndpointURL: assetsEndpointURL
            )
        }
    }
}
