import Campaign
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsNavigationViewModel: ObservableObject {

    public init() {}
    public var connectPaymentVm = ConnectPaymentViewModel()
}

public struct PaymentsNavigation<Content: View>: View {
    @ViewBuilder var redirect: (_ type: PaymentsRedirectType) -> Content
    @EnvironmentObject var router: Router
    @ObservedObject var paymentsNavigationVm: PaymentsNavigationViewModel

    public init(
        paymentsNavigationVm: PaymentsNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: PaymentsRedirectType) -> Content
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router, tracking: PaymentsDetentActions.paymentsView) {
            PaymentsView()
                .configureTitle(L10n.myPaymentTitle)
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                        .configureTitleView(paymentData)
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    Group {
                        switch routerAction {
                        case .discounts:
                            let store: PaymentStore = globalPresentableStoreContainer.get()
                            let paymentDataDiscounts = store.state.paymentData?.discounts ?? []
                            CampaignNavigation(
                                campaignNavigationVm: .init(paymentDataDiscounts: paymentDataDiscounts),
                                redirect: { redirect in
                                    switch redirect {
                                    case .forever:
                                        self.redirect(.forever)
                                    }
                                },
                                onEditCode: {
                                    store.send(.load)
                                }
                            )
                        case .history:
                            PaymentHistoryView()
                                .configureTitle(L10n.paymentHistoryTitle)
                        }
                    }
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

public enum PaymentsRouterAction: Hashable {
    case discounts
    case history
}

extension PaymentsRouterAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        }
    }
}

public enum PaymentsRedirectType: Hashable {
    case forever
}

extension PaymentsRedirectType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .forever:
            return "Forever"
        }
    }
}

#Preview {
    PaymentsNavigation(paymentsNavigationVm: .init(), redirect: { redirectType in })
}
