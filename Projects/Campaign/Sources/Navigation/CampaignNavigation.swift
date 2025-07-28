import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
class CampaignNavigationViewModel: ObservableObject {
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
            .routerDestination(for: CampaignRouterAction.self) { type in
                ForeverNavigation(useOwnNavigation: false)
                    .hideToolbar()
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
