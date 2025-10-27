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

public struct PaymentsNavigation: View {
    @EnvironmentObject var router: Router
    @ObservedObject var paymentsNavigationVm: PaymentsNavigationViewModel

    public init(
        paymentsNavigationVm: PaymentsNavigationViewModel
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
    }

    public var body: some View {
        RouterHost(router: router, tracking: PaymentsDetentActions.paymentsView) {
            PaymentsView()
                .configureTitle(L10n.myPaymentTitle)
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                        .configureTitleView(title: paymentData.title, titleColor: paymentData.titleColor, topPadding: 0)
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    switch routerAction {
                    case .discounts:
                        CampaignNavigation(
                            onEditCode: {
                                let store: PaymentStore = globalPresentableStoreContainer.get()
                                store.send(.load)
                            }
                        )
                    case .history:
                        PaymentHistoryView()
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

public enum PaymentsRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case discounts
    case history

    public var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .discounts:
            L10n.paymentsDiscountsSectionTitle
        case .history:
            L10n.paymentHistoryTitle
        }
    }
}

extension PaymentData: NavigationTitleProtocol {
    public var navigationTitle: String? {
        title
    }
}

#Preview {
    PaymentsNavigation(paymentsNavigationVm: .init())
        .environmentObject(Router())
}
