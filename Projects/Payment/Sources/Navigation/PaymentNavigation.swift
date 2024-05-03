import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class PaymentsNavigationViewModel: ObservableObject {
    @Published public var isAddCampaignPresented = false
}

public enum PaymentsRouterAction {
    case discounts
}

public struct PaymentsNavigation<Content: View>: View {
    @ViewBuilder var redirect: (_ type: PaymentsRedirectType) -> Content
    @StateObject var router = Router()
    @StateObject var paymentsNavigationVm = PaymentsNavigationViewModel()
    @State var cancellable: AnyCancellable?

    public init(
        @ViewBuilder redirect: @escaping (_ type: PaymentsRedirectType) -> Content
    ) {
        self.redirect = redirect
    }

    public var body: some View {
        RouterHost(router: router) {
            PaymentsView()
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                        .configureTitle(L10n.paymentsUpcomingPayment)
                }
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    switch routerAction {
                    case .discounts:
                        PaymentsDiscountsRootView()
                            .onAppear {
                                let store: PaymentStore = globalPresentableStoreContainer.get()
                                store.send(.fetchDiscountsData)
                            }
                            .routerDestination(for: PaymentsRedirectType.self) { redirectType in
                                switch redirectType {
                                case .forever:
                                    redirect(.forever)
                                }
                            }
                            .configureTitle(L10n.paymentsDiscountsSectionTitle)
                    }
                }
        }
        .onAppear {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case let .navigation(to):
                    switch to {
                    case .goBack:
                        router.dismiss()
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        .environmentObject(paymentsNavigationVm)
        .detent(
            presented: $paymentsNavigationVm.isAddCampaignPresented,
            style: .height
        ) {
            AddCampaingCodeView()
                .configureTitle(L10n.paymentsAddCampaignCode)
                .embededInNavigation(options: .navigationType(type: .large))
        }
    }
}

public enum PaymentsRedirectType: Hashable {
    case forever
}

#Preview{
    PaymentsNavigation(redirect: { redirectType in })
}
