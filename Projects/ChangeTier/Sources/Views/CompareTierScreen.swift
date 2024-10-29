import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: CompareTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        succesView.loading($vm.viewState)
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            vm.getProductVariantComparision()
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                changeTierNavigationVm.router.dismiss()
                            }
                        )
                )
            )
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

public class CompareTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var tiers: [Tier]

    @Published var perils: [String: [Perils]] = [:]
    @Published var limits: [String: [InsurableLimits]] = [:]
    var scrollableSegmentedViewModel: ScrollableSegmentedViewModel = .init(pageModels: [])

    init(
        tiers: [Tier],
        selectedTier: Tier? = nil
    ) {
        self.selectedTier = selectedTier
        self.tiers = tiers
        self.getProductVariantComparision()
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

    public func getProductVariantComparision() {
        withAnimation {
            viewState = .loading
        }
        Task { @MainActor in
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

                //                let mockTermsVersionsToCompare =
                //                [
                //                    "SE_DOG_BASIC-20230330-HEDVIG-null",
                //                    "SE_DOG_STANDARD-20230330-HEDVIG-null",
                //                    "SE_DOG_PREMIUM-20230410-HEDVIG-null"
                //                ]

                let productVariantComparisionData = try await service.compareProductVariants(
                    termsVersion: termsVersionsToCompare
                        //                    termsVersion: mockTermsVersionsToCompare
                )

                let columns = productVariantComparisionData.variantColumns
                let rows = productVariantComparisionData.rows
                let tierNames = columns.compactMap({ $0.displayNameTier })

                self.limits = Dictionary(
                    uniqueKeysWithValues: productVariantComparisionData.variantColumns
                        .map({
                            (
                                $0.displayNameTier ?? "",
                                $0.insurableLimits
                            )
                        })
                )

                self.perils = getPerils(tierNames: tierNames, rows: rows)

                let pageModels: [PageModel] = tierNames.compactMap({ PageModel(id: $0, title: $0) })
                let currentId = productVariantComparisionData.variantColumns
                    .first(where: { $0.displayNameTier == selectedTier?.name })?
                    .displayNameTier

                self.scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
                    pageModels: pageModels,
                    currentId: currentId
                )

                withAnimation {
                    viewState = .success
                }
            } catch let error {
                withAnimation {
                    self.viewState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }
}
