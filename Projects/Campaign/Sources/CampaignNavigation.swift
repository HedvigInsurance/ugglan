import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class CampaignNavigationViewModel: ObservableObject {
    @Published public var isAddCampaignPresented = false
    @Published public var isDeleteCampaignPresented: Discount?
    var paymentDataDiscounts: [Discount]
    let router: Router

    public init(
        paymentDataDiscounts: [Discount],
        router: Router
    ) {
        self.paymentDataDiscounts = paymentDataDiscounts
        self.router = router
    }
}

public struct CampaignNavigation: View {
    @ObservedObject var campaignNavigationVm: CampaignNavigationViewModel
    let onEditCode: () -> Void

    public init(
        campaignNavigationVm: CampaignNavigationViewModel,
        onEditCode: @escaping () -> Void
    ) {
        self.campaignNavigationVm = campaignNavigationVm
        self.onEditCode = onEditCode
    }

    public var body: some View {
        PaymentsDiscountsRootView(campaignNavigationVm: campaignNavigationVm)
            .onAppear {
                let store: CampaignStore = globalPresentableStoreContainer.get()
                store.send(.fetchDiscountsData(paymentDataDiscounts: campaignNavigationVm.paymentDataDiscounts))
            }
            .configureTitle(L10n.paymentsDiscountsSectionTitle)
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
            .routerDestination(for: CampaignRouterAction.self) { type in
                ForeverNavigation(useOwnNavigation: false)
                    .hideToolbar()
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
    case forever
}

extension CampaignRouterAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .forever:
            return .init(describing: ForeverNavigation.self)
        }
    }
}

#Preview {
    CampaignNavigation(campaignNavigationVm: .init(paymentDataDiscounts: [], router: Router()), onEditCode: {})
}
