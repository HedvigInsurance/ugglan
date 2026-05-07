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
                    case .changePayoutMethod:
                        PayoutChangeMethodScreen()
                    }
                }
        }
    }
}

enum PayoutRouterActions: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case selectedPayoutMethod
    case changePayoutMethod

    var nameForTracking: String {
        switch self {
        case .selectedPayoutMethod:
            return String(describing: PayoutSelectedMethodScreen.self)
        case .changePayoutMethod:
            return String(describing: PayoutChangeMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .selectedPayoutMethod:
            return L10n.payoutPageHeading
        case .changePayoutMethod:
            return L10n.payoutSelectPayoutMethod
        }
    }
}
