import Campaign
import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsNavigationViewModel: ObservableObject {
    private var paymentStoreSubscription: AnyCancellable?
    @Published var showNordeaSetup = false

    var paymentStatusViewModel: PaymentStatusViewModel?
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

class PaymentStatusViewModel: ObservableObject {
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
                    case let .paymentMethod(data, chargingDay):
                        PaymentMethodScreen(data: data, chargingDay: chargingDay)
                    }
                }
                .routerDestination(for: PayoutRouterAction.self) { routerAction in
                    switch routerAction {
                    case .payoutMethod:
                        PayoutSelectedMethodScreen(vm: paymentsNavigationVm.paymentStatusViewModel!)
                    case .setupPayoutMethod:
                        PayoutChangeMethodScreen(vm: paymentsNavigationVm.paymentStatusViewModel!)
                    }
                }
        }
        .environmentObject(paymentsNavigationVm)
        .handleConnectPayment(with: paymentsNavigationVm.connectPaymentVm)
        .detent(
            presented: $paymentsNavigationVm.showNordeaSetup,
            presentationStyle: .detent(style: [.height])
        ) {
            NordeaPayoutSetupScreen() { [weak router] in
                router?.pop()
            }
        }
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
enum PayoutRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case payoutMethod
    case setupPayoutMethod

    var nameForTracking: String {
        switch self {
        case .payoutMethod:
            return .init(describing: PayoutSelectedMethodScreen.self)
        case .setupPayoutMethod:
            return .init(describing: PayoutChangeMethodScreen.self)
        }
    }

    var navigationTitle: String? {
        switch self {
        case .payoutMethod:
            return L10n.payoutPageHeading
        case .setupPayoutMethod:
            return L10n.payoutSelectPayoutMethod
        }
    }
}

enum PaymentsRouterAction: Hashable, TrackingViewNameProtocol, NavigationTitleProtocol {
    case discounts
    case history
    case paymentMethod(data: PaymentMethodData, chargingDay: Int?)

    var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        case .history:
            return .init(describing: PaymentHistoryView.self)
        case .paymentMethod:
            return .init(describing: PaymentMethodScreen.self)
        }
    }

    var navigationTitle: String? {
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
