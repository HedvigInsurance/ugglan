import Foundation
import SwiftUI
import hCoreUI

public class SelectTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented = false
    @Published public var isEditDeductiblePresented = false

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
            EditDeductibleView(vm: selectTierNavigationVm.vm)
                .configureTitle("Select your deductible")
                .embededInNavigation(options: .navigationType(type: .large))
                .environmentObject(selectTierNavigationVm)
        }
    }
}
