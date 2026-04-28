import Campaign
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsNavigationViewModel: ObservableObject {
    private var paymentStoreSubscription: AnyCancellable?
    public private(set) var paymentStatusViewModel: PaymentStatusViewModel?
    public var connectPaymentVm = ConnectPaymentViewModel()

    public init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        paymentStoreSubscription = store.stateSignal.map(\.paymentStatusData)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] value in
                if let value {
                    if self?.paymentStatusViewModel == nil {
                        self?.paymentStatusViewModel = .init(paymentStatusData: value)
                    } else {
                        self?.paymentStatusViewModel?.paymentStatusData = value
                    }
                } else {
                    self?.paymentStatusViewModel = nil
                }
            })
    }
}

public class PaymentStatusViewModel: ObservableObject {
    @Published var paymentStatusData: PaymentStatusData

    init(paymentStatusData: PaymentStatusData) {
        self.paymentStatusData = paymentStatusData
    }
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
                    case .paymentMethod:
                        PaymentMethodScreen()
                    case .payoutMethod:
                        if let vm = paymentsNavigationVm.paymentStatusViewModel {
                            PayoutSelectedMethodScreen(vm: vm)
                        }
                    }
                }
                .routerDestination(for: PayoutRouterActions.self) { routerAction in
                    switch routerAction {
                    case .selectedPayoutMethod:
                        if let vm = paymentsNavigationVm.paymentStatusViewModel {
                            PayoutSelectedMethodScreen(vm: vm)
                        }
                    case .changePayoutMethod:
                        if let vm = paymentsNavigationVm.paymentStatusViewModel {
                            PayoutChangeMethodScreen(vm: vm)
                        }
                    }
                }
                .routerDestination(for: PayoutRouterActions.self) { routerAction in
                    switch routerAction {
                    case .selectedPayoutMethod:
                        PayoutSelectedMethodScreen(vm: paymentsNavigationVm.paymentStatusViewModel!)
                    case .changePayoutMethod:
                        PayoutChangeMethodScreen(vm: paymentsNavigationVm.paymentStatusViewModel!)
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
