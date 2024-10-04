import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    private var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    var perils: [Perils] = []
    let limits: [InsurableLimits]

    private let scrollableSegmentedViewModel: ScrollableSegmentedViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm

        let currentTier = vm.tiers.first(where: { $0.id == vm.selectedTier?.id })
        self.limits = currentTier?.productVariant?.insurableLimits ?? []

        self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
            pageModels: vm.tiers.compactMap({ .init(id: $0.id, title: $0.name) })
        )
        self.perils = getFilteredPerils(currentTier: currentTier)
    }

    var body: some View {
        hForm {
            ScrollableSegmentedView(
                vm: scrollableSegmentedViewModel,
                contentFor: { id in
                    return CoverageView(
                        limits: limits,
                        didTapInsurableLimit: { limit in
                            changeTierNavigationVm.isInsurableLimitPresented = limit
                        },
                        perils: perils
                    )
                }
            )
        }
    }

    func getFilteredPerils(currentTier: Tier?) -> [Perils] {
        let tierWithMostCoverage = vm.tiers.sorted(by: { $0.level > $1.level }).first
        let maxPerils = tierWithMostCoverage?.productVariant?.perils
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
        return allPerils
    }
}
