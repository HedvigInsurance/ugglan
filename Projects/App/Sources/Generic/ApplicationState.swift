import Flow
import Foundation
import hCore
import hGraphQL
import Market
import Offer
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

    static func presentRootViewController(_ window: UIWindow) -> Disposable {
        guard let applicationState = currentState
        else {
            return window.present(
                MarketPicker(),
                options: [.defaults],
                animated: false
            )
        }

        switch applicationState {
        case .marketPicker, .languagePicker:
            return window.present(
                MarketPicker(),
                options: [.defaults],
                animated: false
            )
        case .marketing:
            return window.present(
                Marketing(),
                options: [.defaults],
                animated: false
            )
        case .onboardingChat, .onboarding:
            return window.present(
                Onboarding(),
                options: [.defaults, .prefersLargeTitles(true)],
                animated: false
            )
        case .offer:
            return window.present(
                Offer(
                    offerIDContainer: .stored,
                    menu: Menu(
                        title: nil,
                        children: [
                            MenuChild.appInformation,
                            MenuChild.appSettings,
                            MenuChild.login(onLogin: {
                                UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
                            })
                        ]
                    )
                ),
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
