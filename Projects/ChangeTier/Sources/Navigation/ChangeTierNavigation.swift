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

    let router = Router()
    var vm: ChangeTierViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }
}

public enum ChangeTierSource {
    case changeTier
    case betterPrice
    case betterCoverage
    case moving
}

public struct ChangeTierNavigation: View {
    @ObservedObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    public init(
        contractId: String,
        changeTierSource: ChangeTierSource
    ) {
        self.changeTierNavigationVm = .init(
            vm: .init(
                contractId: contractId,
                changeTierSource: changeTierSource
            )
        )
    }

    public var body: some View {
        RouterHost(router: changeTierNavigationVm.router, options: []) {
            ChangeTierLandingScreen(vm: changeTierNavigationVm.vm)
                .withDismissButton()
        }
        .environmentObject(changeTierNavigationVm)
        .detent(
            presented: $changeTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTierScreen(vm: changeTierNavigationVm.vm)
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(changeTierNavigationVm)
        }
        .detent(
            presented: $changeTierNavigationVm.isEditDeductiblePresented,
            style: [.height]
        ) {
            EditDeductibleScreen(vm: changeTierNavigationVm.vm)
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
        .modally(presented: $changeTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(vm: changeTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowCompareButton)
                .withDismissButton()
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(changeTierNavigationVm)
        }
    }
}
