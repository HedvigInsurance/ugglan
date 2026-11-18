import SwiftUI
import hCore
import hCoreUI

/// Modal flow for adding a power of attorney: choose co-insured -> sign with BankID -> share.
struct PowerOfAttorneyNavigation: View {
    @State private var router = NavigationRouter()

    var body: some View {
        hNavigationStack(router: router, tracking: self) {
            PowerOfAttorneySelectCoInsuredScreen()
                .withDismissButton()
                .routerDestination(for: PowerOfAttorneyRouterType.self) { routerType in
                    switch routerType {
                    case let .signing(user, level):
                        PowerOfAttorneySigningScreen(user: user, level: level)
                    }
                }
                // No way back to the signing screen once the power of attorney is signed
                .routerDestination(for: PowerOfAttorneySuccessRouterType.self, options: [.hidesBackButton]) {
                    routerType in
                    switch routerType {
                    case let .success(user, shareUrl):
                        PowerOfAttorneySuccessScreen(user: user, shareUrl: shareUrl)
                    }
                }
        }
    }
}

extension PowerOfAttorneyNavigation: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: PowerOfAttorneySelectCoInsuredScreen.self)
    }
}

enum PowerOfAttorneyRouterType: Hashable {
    case signing(user: PowerOfAttorneyUser, level: PowerOfAttorney.Level)
}

extension PowerOfAttorneyRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .signing:
            return .init(describing: PowerOfAttorneySigningScreen.self)
        }
    }
}

enum PowerOfAttorneySuccessRouterType: Hashable {
    case success(user: PowerOfAttorneyUser, shareUrl: URL)
}

extension PowerOfAttorneySuccessRouterType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .success:
            return .init(describing: PowerOfAttorneySuccessScreen.self)
        }
    }
}
