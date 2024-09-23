import SwiftUI
import hCore
import hCoreUI

struct CompareTierScreen: View {
    var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: SelectTierNavigationViewModel

    var scrollableSegmentedViewModel: ScrollableSegmentedViewModel

    init(
        vm: SelectTierViewModel
    ) {
        self.vm = vm
        self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
            pageModels: vm.tiers.compactMap({ .init(id: $0.id, title: $0.name) })
        )
    }

    var body: some View {
        hForm {
            ScrollableSegmentedView(
                vm: scrollableSegmentedViewModel,
                contentFor: { id in
                    let tier = vm.tiers.first(where: { $0.id == id })
                    let limits = tier?.productVariant.insurableLimits ?? []
                    let perils = tier?.productVariant.perils ?? []

                    return CoverageView(
                        limits: limits,
                        didTapInsurableLimit: { limit in
                            selectTierNavigationVm.isInsurableLimitPresented = limit
                        },
                        perils: perils
                    )
                }
            )
        }
    }
}
