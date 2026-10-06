import SwiftUI
import hCore
import hCoreUI

public struct PayoutNavigation: View {
    @StateObject private var router = NavigationRouter()
    @EnvironmentObject private var paymentsNavigationVm: PaymentsNavigationViewModel

    public init() {}
    public var body: some View {
        hNavigationStack(router: router, tracking: PayoutRouterActions.selectedPayoutMethod) {
            PayoutSelectedMethodScreen()
                .navigationTitle(L10n.payoutPageHeading)
                .withDismissButton()
                .routerDestination(for: PayoutRouterActions.self) { action in
                    switch action {
                    case .selectedPayoutMethod:
                        PayoutSelectedMethodScreen()
                    }
                }
        }
    }
}

/// The picker is a sheet rather than a destination, so the payout flow has one route left.
enum PayoutRouterActions: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case selectedPayoutMethod

    var nameForTracking: String {
        switch self {
        case .selectedPayoutMethod:
            return String(describing: PayoutSelectedMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .selectedPayoutMethod:
            return L10n.payoutPageHeading
        }
    }
}
