import Campaign
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsNavigationViewModel: ObservableObject {
    private var paymentStoreSubscription: AnyCancellable?
    public var connectPaymentVm = ConnectPaymentViewModel()

    public init() {}
}

public struct PaymentsNavigation: View {
    @EnvironmentObject var router: NavigationRouter
    @ObservedObject var paymentsNavigationVm: PaymentsNavigationViewModel
    public init(
        paymentsNavigationVm: PaymentsNavigationViewModel
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
    }

    public var body: some View {
        hNavigationStack(router: router, tracking: PaymentsDetentActions.paymentsView) {
            PaymentsView()
                .navigationTitle(L10n.myPaymentTitle)
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    switch routerAction {
                    case .discounts:
                        CampaignNavigation()
                    case .history:
                        PaymentHistoryView()
                    case .paymentMethod:
                        PaymentMethodScreen()
                    case .payoutMethod:
                        PayoutSelectedMethodScreen()
                    }
                }
                .routerDestination(for: PayoutRouterActions.self) { routerAction in
                    switch routerAction {
                    case .selectedPayoutMethod:
                        PayoutSelectedMethodScreen()
                    case .changePayoutMethod:
                        PayoutChangeMethodScreen()
                    }
                }
                .routerDestination(for: MissedPaymentData.self) { item in
                    MissedPaymentScreen(missedPaymentdata: item)
                        .navigationTitle(L10n.paymentsPaymentOverdueTitle)
                }
        }
        .environmentObject(paymentsNavigationVm)
        .handleConnectPayment(with: paymentsNavigationVm.connectPaymentVm)
    }
}

private enum PaymentsDetentActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .paymentsView:
            return .init(describing: PaymentsView.self)
        }
    }

    case paymentsView
}

enum PaymentsRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case discounts
    case history
    case paymentMethod
    case payoutMethod

    var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        case .paymentMethod:
            return .init(describing: PaymentMethodScreen.self)
        case .payoutMethod:
            return .init(describing: PayoutSelectedMethodScreen.self)
        }
    }

    var navigationTitle: String? {
        switch self {
        case .discounts:
            return L10n.paymentsDiscountsSectionTitle
        case .history:
            return L10n.paymentHistoryTitle
        case .paymentMethod:
            return L10n.PaymentDetails.NavigationBar.title
        case .payoutMethod:
            return L10n.payoutPageHeading
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PaymentsNavigation(paymentsNavigationVm: .init())
        .environmentObject(NavigationRouter())
}
