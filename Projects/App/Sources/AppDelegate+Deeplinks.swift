import CoreDependencies
import FirebaseAnalytics
import Flow
import Foundation
import Payment
import Presentation
import hCore

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL) -> Bool {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return false
        }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
        guard let rootViewController = window.rootViewController else { return false }

        Analytics.track(path.trackingName, properties: [:])
        Analytics.track(path.deprecatedTrackingName, properties: ["type": path.rawValue])

        if path == .directDebit {
            bag += rootViewController.present(
                PaymentSetup(setupType: .initial, urlScheme: Bundle.main.urlScheme ?? ""),
                style: .modal,
                options: [.defaults]
            )
        } else {
            bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeTabActive(deeplink: path))
                }
        }

        return true
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
    var trackingName: String {
        "DEEP_LINK_\(self.rawValue.uppercased())"
    }
}

extension DeepLink {
    var deprecatedTrackingName: String {
        return "DEEP_LINK"
    }
}
