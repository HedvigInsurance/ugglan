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

    var vm = SelectTierViewModel()

    init() {}
}

public struct ChangeTierNavigation: View {
    @StateObject var router = Router()
    @StateObject var selectTierNavigationVm = ChangeTierNavigationViewModel()

    public init() {}

    public var body: some View {
        RouterHost(router: router, options: []) {
            ChangeTierLandingScreen(vm: selectTierNavigationVm.vm)
                .withDismissButton()
        }
        .environmentObject(selectTierNavigationVm)
        .detent(
            presented: $selectTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTier(vm: selectTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowSelectCoverageTitle)
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
        .detent(
            presented: $selectTierNavigationVm.isEditDeductiblePresented,
            style: [.height]
        ) {
            EditDeductibleView(vm: selectTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowSelectDeductibleTitle)
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
        .detent(
            item: $selectTierNavigationVm.isInsurableLimitPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
            )
        }
        .detent(
            presented: $selectTierNavigationVm.isTierLockedInfoViewPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) {
            InfoView(
                title: L10n.tierFlowLockedInfoTitle,
                description: L10n.tierFlowLockedInfoDescription
            )
        }
        .modally(presented: $selectTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(vm: selectTierNavigationVm.vm)
                .configureTitle(L10n.tierFlowCompareButton)
                .withDismissButton()
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
    }
}
