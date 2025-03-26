import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@MainActor
public class CampaignNavigationViewModel: ObservableObject {
    @Published public var isAddCampaignPresented = false
    @Published public var isDeleteCampaignPresented: Discount?
    var paymentDataDiscounts: [Discount]

    public let router = Router()

    public init(paymentDataDiscounts: [Discount]) {
        self.paymentDataDiscounts = paymentDataDiscounts
    }
}

public struct CampaignNavigation<Content: View>: View {
    @ViewBuilder var redirect: (_ type: CampaignRedirectType) -> Content
    @ObservedObject var campaignNavigationVm: CampaignNavigationViewModel
    let onEditCode: () -> Void

    public init(
        campaignNavigationVm: CampaignNavigationViewModel,
        @ViewBuilder redirect: @escaping (_ type: CampaignRedirectType) -> Content,
        onEditCode: @escaping () -> Void
    ) {
        self.campaignNavigationVm = campaignNavigationVm
        self.redirect = redirect
        self.onEditCode = onEditCode
    }

    public var body: some View {
        RouterHost(router: campaignNavigationVm.router, tracking: CampaignRouterAction.discounts) {
            PaymentsDiscountsRootView(campaignNavigationVm: campaignNavigationVm)
                .onAppear {
                    let store: CampaignStore = globalPresentableStoreContainer.get()
                    store.send(.fetchDiscountsData(paymentDataDiscounts: campaignNavigationVm.paymentDataDiscounts))
                }
                .routerDestination(for: CampaignRedirectType.self) { redirectType in
                    switch redirectType {
                    case .forever:
                        redirect(.forever)
                    }
                }
                .configureTitle(L10n.paymentsDiscountsSectionTitle)
        }
        .environmentObject(campaignNavigationVm)
        .detent(
            presented: $campaignNavigationVm.isAddCampaignPresented,
            style: [.height]
        ) {
            AddCampaignCodeView(
                campaignNavigationVm: campaignNavigationVm,
                vm: .init(
                    paymentDataDiscounts: campaignNavigationVm.paymentDataDiscounts,
                    onInputChange: onEditCode
                )
            )
            .configureTitle(L10n.paymentsAddCampaignCode)
            .embededInNavigation(
                options: .navigationType(type: .large),
                tracking: CampaignDetentActions.addCampaign
            )
        }
        .detent(
            item: $campaignNavigationVm.isDeleteCampaignPresented,
            style: [.height]
        ) { discount in
            DeleteCampaignView(
                vm: .init(
                    discount: discount,
                    paymentDataDiscounts: campaignNavigationVm.paymentDataDiscounts,
                    onInputChange: onEditCode
                )
            )
            .embededInNavigation(
                options: .navigationType(type: .large),
                tracking: CampaignDetentActions.deleteCampaign
            )
        }
    }
}

private enum CampaignDetentActions: TrackingViewNameProtocol {
    case addCampaign
    case deleteCampaign

    var nameForTracking: String {
        switch self {
        case .addCampaign:
            return .init(describing: AddCampaignCodeView.self)
        case .deleteCampaign:
            return .init(describing: DeleteCampaignView.self)
        }
    }
}

public enum CampaignRouterAction: Hashable {
    case discounts
}

extension CampaignRouterAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .discounts:
            return .init(describing: PaymentsDiscountsRootView.self)
        }
    }
}

public enum CampaignRedirectType: Hashable {
    case forever
}

extension CampaignRedirectType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .forever:
            return "Forever"
        }
    }
}

#Preview {
    CampaignNavigation(campaignNavigationVm: .init(paymentDataDiscounts: []), redirect: { redirect in }, onEditCode: {})
}
