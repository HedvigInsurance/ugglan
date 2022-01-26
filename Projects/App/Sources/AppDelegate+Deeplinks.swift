import CoreDependencies
import FirebaseAnalytics
import Flow
import Foundation
import Payment
import Presentation
import hCore
import hAnalytics

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL) {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return
        }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return }
        guard let rootViewController = window.rootViewController else { return }

        hAnalyticsEvent.deepLinkOpened(type: path.rawValue).send()

        if path == .directDebit {
            rootViewController.present(
                PaymentSetup(setupType: .initial)
                    .journeyThenDismiss
            )
            .onValue { _ in

            }
        } else {
            bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeTabActive(deeplink: path))
                }
        }
    }
}

public enum DeepLink: String, Codable {
    case forever
    case directDebit = "direct-debit"
    case profile
    case insurances
    case home
}

extension DeepLink {
    var deprecatedTrackingName: String {
        "DEEP_LINK_\(self.rawValue.uppercased())"
    }
}

extension DeepLink {
    var trackingName: String {
        return "DEEP_LINK"
    }
}
