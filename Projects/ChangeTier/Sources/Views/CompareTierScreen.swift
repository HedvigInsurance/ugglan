import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    private var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    private var perils: [String: [Perils]]
    private let limits: [String: [InsurableLimits]]
    private let scrollableSegmentedViewModel: ScrollableSegmentedViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
        let columns = vm.productVariantComparision?.variantColumns
        let rows = vm.productVariantComparision?.rows
        let tierNames = columns?.compactMap({ $0.displayNameTier })

        self.limits = Dictionary(
            uniqueKeysWithValues: vm.productVariantComparision?.variantColumns
                .map({
                    (
                        $0.displayNameTier ?? "",
                        $0.insurableLimits
                    )
                }) ?? []
        )

        self.perils = vm.getPerils(tierNames: tierNames, rows: rows)

        let pageModels: [PageModel] = tierNames?.compactMap({ PageModel(id: $0, title: $0) }) ?? []
        let currentId = vm.productVariantComparision?.variantColumns
            .first(where: { $0.displayNameTier == vm.selectedTier?.name })?
            .displayNameTier

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
    fileprivate func getPerils(
        tierNames: [String]?,
        rows: [ProductVariantComparison.ProductVariantComparisonRow]?
    ) -> [String: [Perils]] {
        var tempPerils: [String: [Perils]] = [:]
        var index = 0

        tierNames?
            .forEach({ tierName in
                let cells = rows?
                    .map({ row in
                        let cellForIndex = row.cells[index]
                        return Perils(
                            id: nil,
                            title: row.title,
                            description: row.description,
                            color: row.colorCode,
                            covered: [cellForIndex.coverageText ?? ""],
                            isDisabled: !cellForIndex.isCovered
                        )
                    })

                tempPerils[tierName] = cells
                index = index + 1
            })
        return tempPerils
    }
}
