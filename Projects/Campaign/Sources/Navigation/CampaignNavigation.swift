import Forever
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
class CampaignNavigationViewModel: ObservableObject {}

public struct CampaignNavigation: View {
    @StateObject var campaignNavigationVm = CampaignNavigationViewModel()

    public init() {}

    public var body: some View {
        PaymentsDiscountsRootView()
            .onAppear {
                let store: CampaignStore = globalPresentableStoreContainer.get()
                store.send(.fetchDiscountsData)
            }
            .configureTitle(L10n.paymentsDiscountsSectionTitle)
            .environmentObject(campaignNavigationVm)
            .routerDestination(for: CampaignRouterAction.self) { _ in
                ForeverNavigation(useOwnNavigation: false)
                    .toolbar(.hidden, for: .tabBar)
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
    CampaignNavigation()
}
