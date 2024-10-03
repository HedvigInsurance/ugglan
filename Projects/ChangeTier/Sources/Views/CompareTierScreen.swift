import SwiftUI
import hCore
import hCoreUI

struct CompareTierScreen: View {
    private var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    private let scrollableSegmentedViewModel: ScrollableSegmentedViewModel

    init(
        vm: ChangeTierViewModel
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
                    let currentTier = vm.tiers.first(where: { $0.id == id })
                    let tierWithMostCoverage = vm.tiers.sorted(by: { $0.level > $1.level }).first
                    let maxPerils = tierWithMostCoverage?.productVariant?.perils

                    let currentLimits = currentTier?.productVariant?.insurableLimits ?? []
                    let currentPerils = currentTier?.productVariant?.perils ?? []

                    let perilsNotCoveredByTier =
                        maxPerils?.filter({ !currentPerils.contains($0) })
                        .map({
                            Perils(
                                id: $0.id,
                                title: $0.title,
                                description: $0.description,
                                info: $0.info,
                                color: $0.color,
                                covered: $0.covered,
                                isDisabled: true
                            )
                        }) ?? []

                    let allPerils = currentPerils + perilsNotCoveredByTier

                    return CoverageView(
                        limits: currentLimits,
                        didTapInsurableLimit: { limit in
                            changeTierNavigationVm.isInsurableLimitPresented = limit
                        },
                        perils: allPerils
                    )
                }
            )
        }
    }
}
