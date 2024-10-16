import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    private var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    private let perils: [String: [Perils]]
    private let limits: [String: [InsurableLimits]]
    private let scrollableSegmentedViewModel: ScrollableSegmentedViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm

        let selectedQuote = vm.selectedQuote

        self.limits = Dictionary(
            uniqueKeysWithValues: vm.tiers.map({
                (
                    $0.id,
                    $0.quotes.first(where: { quote in
                        quote.id == selectedQuote?.id
                    })?
                    .productVariant?
                    .insurableLimits ?? $0.quotes.first(where: { quote in
                        quote == selectedQuote
                    })?
                    .productVariant?
                    .insurableLimits ?? []
                )
            })
        )

        self.perils = Dictionary(
            uniqueKeysWithValues: vm.tiers.map({
                ($0.id, vm.getFilteredPerils(currentTier: $0, selectedQuote: selectedQuote))
            })
        )
        let pageModels: [PageModel] = vm.tiers.compactMap({ PageModel(id: $0.id, title: $0.name) })
        let currentId = vm.tiers.first(where: { $0.id == vm.selectedTier?.name })?.id
        self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
            pageModels: pageModels,
            currentId: currentId
        )
    }

    var body: some View {
        hForm {
            ScrollableSegmentedView(
                vm: scrollableSegmentedViewModel,
                contentFor: { id in
                    return CoverageView(
                        limits: limits[id] ?? [],
                        didTapInsurableLimit: { limit in
                            changeTierNavigationVm.isInsurableLimitPresented = limit
                        },
                        perils: perils[id] ?? []
                    )
                }
            )
        }
    }
}

extension ChangeTierViewModel {
    fileprivate func getFilteredPerils(currentTier: Tier, selectedQuote: Quote?) -> [Perils] {
        var currentPerils =
            currentTier.quotes.first { quote in
                quote.id == selectedQuote?.id
            }?
            .productVariant?
            .perils ?? currentTier.quotes.first(where: { quote in
                quote == selectedQuote
            })?
            .productVariant?
            .perils ?? currentTier.quotes.first?.productVariant?.perils ?? []

        let otherPerils = self.tiers.filter({ $0.id != currentTier.id })
            .reduce(into: [Perils]()) { partialResult, tier in
                return partialResult.append(contentsOf: tier.quotes.first?.productVariant?.perils ?? [])
            }

        for otherPeril in otherPerils {
            if !currentPerils.compactMap({ $0.title }).contains(otherPeril.title) {
                currentPerils.append(otherPeril.asDisabled())
            }
        }
        return currentPerils
    }
}
