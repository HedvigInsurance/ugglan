import Foundation
import SwiftUI
import hCoreUI

public class SelectTierNavigationViewModel: ObservableObject {
    @Published public var isEditTierPresented = false
}

public struct SelectTierNavigation: View {
    @StateObject var router = Router()
    @StateObject var selectTierNavigationVm = SelectTierNavigationViewModel()

    public init() {}

    public var body: some View {
        RouterHost(router: router, options: []) {
            SelectTier()
        }
        .environmentObject(selectTierNavigationVm)
        .detent(
            presented: $selectTierNavigationVm.isEditTierPresented,
            style: [.height]
        ) {
            EditTier()
                .configureTitle("Select your coverage")
                .embededInNavigation(options: .navigationType(type: .large))
        }
    }
}
