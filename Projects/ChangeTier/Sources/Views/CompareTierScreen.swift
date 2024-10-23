import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class CompareTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var tiers: [Tier]

    var perils: [String: [Perils]] = [:]
    var limits: [String: [InsurableLimits]] = [:]
    var scrollableSegmentedViewModel: ScrollableSegmentedViewModel = .init(pageModels: [])

    init(
        tiers: [Tier],
        selectedTier: Tier? = nil
    ) {
        self.selectedTier = selectedTier
        self.tiers = tiers

        Task {
            let productVariantComparision = try await self.getProductVariantComparision()
            let columns = productVariantComparision?.variantColumns
            let rows = productVariantComparision?.rows
            let tierNames = columns?.compactMap({ $0.displayNameTier })

            self.limits = Dictionary(
                uniqueKeysWithValues: productVariantComparision?.variantColumns
                    .map({
                        (
                            $0.displayNameTier ?? "",
                            $0.insurableLimits
                        )
                    }) ?? []
            )

            self.perils = getPerils(tierNames: tierNames, rows: rows)

            let pageModels: [PageModel] = tierNames?.compactMap({ PageModel(id: $0, title: $0) }) ?? []
            let currentId = productVariantComparision?.variantColumns
                .first(where: { $0.displayNameTier == selectedTier?.name })?
                .displayNameTier

            self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
                pageModels: pageModels,
                currentId: currentId
            )
        }
    }

    private func getPerils(
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

    @MainActor
    public func getProductVariantComparision() async throws -> ProductVariantComparison? {
        withAnimation {
            viewState = .loading
        }
        do {
            var termsVersionsToCompare: [String] = []
            tiers.forEach({ tier in
                tier.quotes.forEach({ quote in
                    if let termsVersion = quote.productVariant?.termsVersion,
                        !termsVersionsToCompare.contains(termsVersion)
                    {
                        termsVersionsToCompare.append(termsVersion)
                    }
                })
            })

            let productVariantComparisionData = try await service.compareProductVariants(
                termsVersion: termsVersionsToCompare
            )

            withAnimation {
                viewState = .success
            }
            return productVariantComparisionData
        } catch let error {
            withAnimation {
                self.viewState = .error(
                    errorMessage: error.localizedDescription
                )
            }
        }
        return nil
    }
}

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: CompareTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowProcessing,
            errorViewButtons: .init(
                actionButton: .init(
                    buttonAction: {
                        Task {
                            try await vm.getProductVariantComparision()
                        }
                    }
                ),
                dismissButton:
                    .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            changeTierNavigationVm.router.dismiss()
                        }
                    )
            ),
            state: $vm.viewState,
            duration: 6
        )
        .hCustomSuccessView {
            succesView
        }
    }

    var succesView: some View {
        hForm {
            ScrollableSegmentedView(
                vm: vm.scrollableSegmentedViewModel,
                contentFor: { id in
                    return CoverageView(
                        limits: vm.limits[id] ?? [],
                        didTapInsurableLimit: { limit in
                            changeTierNavigationVm.isInsurableLimitPresented = limit
                        },
                        perils: vm.perils[id] ?? []
                    )
                }
            )
        }
    }
}
