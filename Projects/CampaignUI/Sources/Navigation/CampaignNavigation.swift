import Forever
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
class CampaignNavigationViewModel {}

public struct CampaignNavigation: View {
    @State var campaignNavigationVm = CampaignNavigationViewModel()

    public init() {}

    public var body: some View {
        PaymentsDiscountsRootView()
            .navigationTitle(L10n.paymentsDiscountsSectionTitle)
            .environment(campaignNavigationVm)
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
