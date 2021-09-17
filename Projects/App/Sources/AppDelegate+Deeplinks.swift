import FirebaseAnalytics
import hCore
import Payment
import Presentation
import Foundation
import Flow
import CoreDependencies

#if PRESENTATION_DEBUGGER
    #if compiler(>=5.5)
import PresentationDebugSupport
#endif
#endif

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL) -> Bool {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else { return false }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return false }
        guard let rootViewController = window.rootViewController else { return false }
        
        Analytics.track(path.trackingName, properties: [:])
        
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
        switch self {
            
        case .forever:
            return "DEEP_LINK_FOREVER"
        case .directDebit:
            return "DEEP_LINK_FOREVER"
        case .profile:
            return "DEEP_LINK_FOREVER"
        case .insurances:
            return "DEEP_LINK_FOREVER"
        case .home:
            return "DEEP_LINK_FOREVER"
        }
    }
}

extension DeepLink {
    
}
