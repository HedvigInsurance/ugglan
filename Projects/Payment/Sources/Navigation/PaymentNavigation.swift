import Presentation
import SwiftUI
import hCore
import hCoreUI

public class PaymentsNavigationViewModel: ObservableObject {

    public init() {}

    @Published public var isAddCampaignPresented = false
    @Published public var isConnectPaymentPresented: SetupTypeNavigationModel?
    @Published public var isDeleteCampaignPresented: Discount?
}

public struct SetupTypeNavigationModel: Equatable, Identifiable {

    public init(
        setUpType: SetupType?
    ) {
        self.setUpType = setUpType
    }

    public var id: String?
    var setUpType: SetupType?
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
        RouterHost(router: router) {
            PaymentsView()
                .configureTitle(L10n.myPaymentTitle)
                .routerDestination(for: PaymentData.self) { paymentData in
                    PaymentDetailsView(data: paymentData)
                        .configureTitleView(paymentData)
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
                                case let .openUrl(url):
                                    redirect(.openUrl(url: url))
                                }
                            }
                            .configureTitle(L10n.paymentsDiscountsSectionTitle)
                    case let .openUrl(url):
                        redirect(.openUrl(url: url))
                    case .history:
                        PaymentHistoryView(vm: .init())
                            .configureTitle(L10n.paymentHistoryTitle)
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
        .detent(
            item: $paymentsNavigationVm.isDeleteCampaignPresented,
            style: .height
        ) { discount in
            DeleteCampaignView(vm: .init(discount: discount))
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            item: $paymentsNavigationVm.isConnectPaymentPresented,
            style: .large
        ) { setupTypeModel in
            let featureFlags: FeatureFlags = Dependencies.shared.resolve()
            switch featureFlags.paymentType {
            case .adyen:
                EmptyView()
                    .onAppear {
                        Task {
                            let paymentServcice: AdyenService = Dependencies.shared.resolve()
                            do {
                                let url = try await paymentServcice.getAdyenUrl()
                                router.push(PaymentsRouterAction.openUrl(url: url))
                            } catch {
                                //we are not so concern about this
                            }
                        }
                    }

            case .trustly:
                DirectDebitSetup()
                    .configureTitle(
                        setupTypeModel.setUpType == .replacement
                            ? L10n.PayInIframeInApp.connectPayment : L10n.PayInIframePostSign.title
                    )
                    .embededInNavigation(options: .navigationType(type: .large))
            }

        }
    }
}

public enum PaymentsRouterAction: Hashable {
    case discounts
    case history
    case openUrl(url: URL)
}

public enum PaymentsRedirectType: Hashable {
    case forever
    case openUrl(url: URL)
}

#Preview{
    PaymentsNavigation(paymentsNavigationVm: .init(), redirect: { redirectType in })
}
