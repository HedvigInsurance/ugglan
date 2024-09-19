import Foundation
import SwiftUI
import hCoreUI
import hCore

public class SelectTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented = false
    @Published public var isEditDeductiblePresented = false
    @Published public var isCompareTiersPresented = false
    @Published public var insurableLimitIsPresented: InsurableLimits?

    var vm = SelectTierViewModel()

    init() {}
}

public struct SelectTierNavigation: View {
    @StateObject var router = Router()
    @StateObject var selectTierNavigationVm = SelectTierNavigationViewModel()

    public init() {}

    public var body: some View {
        RouterHost(router: router, options: []) {
            SelectTierLandingScreen(vm: selectTierNavigationVm.vm)
                .withDismissButton()
        }
        .environmentObject(selectTierNavigationVm)
        .detent(
            presented: $selectTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTier(vm: selectTierNavigationVm.vm)
                .configureTitle("Select your coverage")
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
        .detent(
            presented: $selectTierNavigationVm.isEditDeductiblePresented,
            style: [.height]
        ) {
            EditDeductible(vm: selectTierNavigationVm.vm)
                .configureTitle("Select your deductible")
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
        .detent(
            item: $selectTierNavigationVm.insurableLimitIsPresented,
            style: [.height],
            options: .constant(.alwaysOpenOnTop)
        ) { insurableLimit in
            InfoView(
                title: L10n.contractCoverageMoreInfo,
                description: insurableLimit.description
            )
        }
        .modally(presented: $selectTierNavigationVm.isCompareTiersPresented) {
            CompareTierScreen(vm: selectTierNavigationVm.vm)
                .configureTitle("Compare coverage levels")
                .withDismissButton()
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
    }
}
