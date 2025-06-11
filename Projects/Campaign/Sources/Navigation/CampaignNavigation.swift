import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
class CampaignNavigationViewModel: ObservableObject {
    @Published var isAddCampaignPresented = false
    @Published var isDeleteCampaignPresented: Discount?
}

public struct CampaignNavigation: View {
    @StateObject var campaignNavigationVm = CampaignNavigationViewModel()
    let onEditCode: () -> Void

    public init(
        onEditCode: @escaping () -> Void
    ) {
        self.onEditCode = onEditCode
    }

    public var body: some View {
        PaymentsDiscountsRootView(campaignNavigationVm: campaignNavigationVm)
            .onAppear {
                let store: CampaignStore = globalPresentableStoreContainer.get()
                store.send(.fetchDiscountsData)
            }
            .configureTitle(L10n.paymentsDiscountsSectionTitle)
            .environmentObject(campaignNavigationVm)
            .detent(
                presented: $campaignNavigationVm.isAddCampaignPresented,
                transitionType: .detent(style: [.height])
            ) {
                AddCampaignCodeView(
                    campaignNavigationVm: campaignNavigationVm,
                    vm: .init(
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
                transitionType: .detent(style: [.height])
            ) { discount in
                DeleteCampaignView(
                    vm: .init(
                        discount: discount,
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
    CampaignNavigation(onEditCode: {})
}
