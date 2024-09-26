import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class ChangeTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented = false
    @Published public var isEditDeductiblePresented = false
    @Published public var isCompareTiersPresented = false
    @Published public var isInsurableLimitPresented: InsurableLimits?
    @Published public var isTierLockedInfoViewPresented = false

    @StateObject var router = Router()
    var vm = ChangeTierViewModel()

    init() {}
}

enum ChangeTierRouterActions {
    case summary
}

extension ChangeTierRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .summary:
            return "Change tier summary"
        }
    }
}

public enum ChangeTierSource {
    case termination
    case moving
}

public struct ChangeTierNavigation: View {
    @StateObject var changeTierNavigationVm = ChangeTierNavigationViewModel()
    var contractId: String
    var changeTierSource: ChangeTierSource

    public init(
        contractId: String,
        changeTierSource: ChangeTierSource
    ) {
        self.contractId = contractId
        self.changeTierSource = changeTierSource
    }

    public var body: some View {
        RouterHost(router: changeTierNavigationVm.router, options: []) {
            ChangeTierLandingScreen(vm: changeTierNavigationVm.vm, contractId: contractId)
                .withDismissButton()
                .routerDestination(for: ChangeTierRouterActions.self) { action in
                    switch action {
                    case .summary:
                        ChangeTierSummaryScreen(vm: selectTierNavigationVm.vm)
                            .configureTitle("Summary")
                    }
                }
        }
        .environmentObject(changeTierNavigationVm)
        .detent(
            presented: $changeTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTier(vm: changeTierNavigationVm.vm)
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            presented: $changeTierNavigationVm.isEditDeductiblePresented,
            style: [.height]
        ) {
            EditDeductibleView(vm: changeTierNavigationVm.vm)
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            item: $changeTierNavigationVm.isInsurableLimitPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
            )
        }
        .detent(
            presented: $changeTierNavigationVm.isTierLockedInfoViewPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) {
            InfoView(
                title: L10n.tierFlowLockedInfoTitle,
                description: L10n.tierFlowLockedInfoDescription
            )
        }
        .modally(presented: $changeTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(vm: changeTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowCompareButton)
                .withDismissButton()
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(changeTierNavigationVm)
        }
    }
}
