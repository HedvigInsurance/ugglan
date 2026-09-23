import CampaignUI
import Combine
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsNavigationViewModel: ObservableObject {
    private var paymentStoreSubscription: AnyCancellable?
    let paymentsRouter = NavigationRouter()
    @Published var showChooseDefaultPaymentMethod = false
    @Published var showAddPaymentMethod = false
    public init() {}
}

public struct PaymentsNavigation: View {
    @ObservedObject var paymentsNavigationVm: PaymentsNavigationViewModel
    public init(
        paymentsNavigationVm: PaymentsNavigationViewModel
    ) {
        self.paymentsNavigationVm = paymentsNavigationVm
    }

    public var body: some View {
        hNavigationStack(router: paymentsNavigationVm.paymentsRouter, tracking: PaymentsDetentActions.paymentsView) {
            PaymentsView()
                .navigationTitle(L10n.myPaymentTitle)
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    paymentsDestination(for: routerAction)
                }
                .routerDestination(for: PayoutRouterActions.self) { routerAction in
                    switch routerAction {
                    case .selectedPayoutMethod:
                        PayoutSelectedMethodScreen()
                    }
                }
                .routerDestination(for: MissedPaymentData.self) { item in
                    MissedPaymentScreen(
                        missedPaymentdata: item,
                        onSuccess: {
                            Task { @MainActor in
                                paymentsNavigationVm.paymentsRouter.popToRoot()
                            }
                        }
                    )
                    .navigationTitle(L10n.paymentsPaymentOverdueTitle)
                }
        }
        .withPaymentsPresentations(paymentsNavigationVm)
    }
}

@MainActor
@ViewBuilder
func paymentsDestination(for routerAction: PaymentsRouterAction) -> some View {
    switch routerAction {
    case .discounts:
        CampaignNavigation()
    case .history:
        PaymentHistoryView()
    case let .paymentMethod(provider):
        PaymentMethodScreen(paymentProvider: provider)
    case .paymentMethods:
        PaymentMethodsScreen()
    }
}

extension View {
    func withPaymentsPresentations(_ vm: PaymentsNavigationViewModel) -> some View {
        modifier(PaymentsPresentations(vm: vm))
    }
}

private struct PaymentsPresentations: ViewModifier {
    @ObservedObject var vm: PaymentsNavigationViewModel

    func body(content: Content) -> some View {
        content
            .environmentObject(vm)
            .detent(
                presented: $vm.showChooseDefaultPaymentMethod,
                presentationStyle: .detent(style: [.height])
            ) {
                PaymentsChooseDefaultScreen()
            }
            .handleAddPaymentMethod(presented: $vm.showAddPaymentMethod)
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
    case paymentMethod(provider: PaymentProvider)
    case paymentMethods

    var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        case .paymentMethod:
            return .init(describing: PaymentMethodScreen.self)
        case .paymentMethods:
            return .init(describing: PaymentMethodsScreen.self)
        }
    }

    var navigationTitle: String? {
        switch self {
        case .discounts:
            return L10n.paymentsDiscountsSectionTitle
        case .history:
            return L10n.paymentHistoryTitle
        case .paymentMethod:
            return L10n.paymentMethodTitle
        case .paymentMethods:
            return L10n.paymentMethodsTitle
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PaymentsNavigation(paymentsNavigationVm: .init())
}
