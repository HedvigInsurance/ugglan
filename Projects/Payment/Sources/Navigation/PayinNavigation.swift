import SwiftUI
import hCore
import hCoreUI

public struct PayinNavigation: View {
    @StateObject private var router = NavigationRouter()
    @EnvironmentObject private var paymentsNavigationVm: PaymentsNavigationViewModel

    public init() {}
    public var body: some View {
        hNavigationStack(router: router, tracking: PayinRouterActions.overview) {
            PayinOverviewScreen()
                .navigationTitle("Payin account")  //L10n.payinPageHeading
                .withDismissButton()
                .routerDestination(for: PayinRouterActions.self) { action in
                    switch action {
                    case .overview:
                        PayinOverviewScreen()
                    case .changePayinMethod:
                        PayinChangeMethodScreen()
                    }
                }
        }
    }
}

enum PayinRouterActions: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case overview
    case changePayinMethod

    var nameForTracking: String {
        switch self {
        case .overview:
            return String(describing: PayinOverviewScreen.self)
        case .changePayinMethod:
            return String(describing: PayinChangeMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .overview:
            return "Payin account"  //L10n.payinPageHeading
        case .changePayinMethod:
            return "Choose payin method"  //L10n.payinSelectPayinMethod
        }
    }
}
