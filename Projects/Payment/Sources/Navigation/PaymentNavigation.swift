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
    @EnvironmentObject var router: NavigationRouter
    @ObservedObject var paymentsNavigationVm: PaymentsNavigationViewModel
    @Inject var store: PaymentStore
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
                        .configureTitleView(
                            title: paymentData.title,
                            titleColor: paymentData.titleColor,
                            topPadding: 0,
                            alignment: .center
                        )
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    switch routerAction {
                    case .discounts:
                        CampaignNavigation()
                    case .history:
                        PaymentHistoryView()
                    case let .paymentMethod(data, chargingDay):
                        PaymentMethodScreen(data: data, chargingDay: chargingDay)
                    }
                }
                .routerDestination(for: PayoutRouterAction.self) { routerAction in
                    switch routerAction {
                    case .payoutMethod:
                        PresentableStoreLens(
                            PaymentStore.self,
                            getter: { state in
                                state.paymentStatusData
                            }
                        ) { paymentStatusData in
                            if let paymentStatusData {
                                PayoutSelectedMethodScreen(paymentStatusData: paymentStatusData)
                            }
                        }
                    case .setupPayoutMethod:
                        PresentableStoreLens(
                            PaymentStore.self,
                            getter: { state in
                                state.paymentStatusData?.availableMethods ?? []
                            }
                        ) { availableMethods in
                            PayoutChangeMethodScreen(availableMethods: availableMethods)
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
public enum PayoutRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case payoutMethod
    case setupPayoutMethod

    public var nameForTracking: String {
        switch self {
        case .payoutMethod:
            return .init(describing: PayoutSelectedMethodScreen.self)
        case .setupPayoutMethod:
            return .init(describing: PayoutChangeMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .payoutMethod:
            return .init(describing: PayoutSelectedMethodScreen.self)
        case .setupPayoutMethod:
            return .init(describing: PayoutChangeMethodScreen.self)
        }
    }
}
public enum PaymentsRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case discounts
    case history
    case paymentMethod(data: PaymentMethodData, chargingDay: Int?)

    public var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        case .paymentMethod:
            return .init(describing: PaymentMethodScreen.self)
        }
    }

    public var navigationTitle: String? {
        switch self {
        case .discounts:
            L10n.paymentsDiscountsSectionTitle
        case .history:
            L10n.paymentHistoryTitle
        case .paymentMethod:
            L10n.PaymentDetails.NavigationBar.title
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PaymentsNavigation(paymentsNavigationVm: .init())
        .environmentObject(NavigationRouter())
}
