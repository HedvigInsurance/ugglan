import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    let mockPerils: [String: [Perils]] = [
        "Bas":
            [
                Perils(
                    id: "peril1",
                    title: "Veterinary care",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
                Perils(
                    id: "peril2",
                    title: "Hidden defects",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: true
                ),
                Perils(
                    id: "peril3",
                    title: "Giving birth",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: true
                ),
            ],
        "Standard":
            [
                Perils(
                    id: "peril1",
                    title: "Veterinary care",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
                Perils(
                    id: "peril2",
                    title: "Hidden defects",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
                Perils(
                    id: "peril3",
                    title: "Giving birth",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: true
                ),
            ],
        "Premium":
            [
                Perils(
                    id: "peril1",
                    title: "Veterinary care",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
                Perils(
                    id: "peril2",
                    title: "Hidden defects",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
                Perils(
                    id: "peril3",
                    title: "Giving birth",
                    description: "description",
                    color: nil,
                    covered: [""],
                    isDisabled: false
                ),
            ],
    ]

    let mockTiers: [Tier] = [
        .init(id: "BAS", name: "Bas", level: 1, quotes: [], exposureName: "Bas"),
        .init(id: "STANDARD", name: "Standard", level: 2, quotes: [], exposureName: "Standard"),
        .init(id: "PREMIUM", name: "Premium", level: 3, quotes: [], exposureName: "Premium"),
    ]

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

    @ViewBuilder
    var succesView: some View {
        hForm {
            hSection {
                HStack(spacing: 0) {
                    getPerilNameColumn()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(mockTiers, id: \.self) { tier in
                                //                    ForEach(vm.tiers, id: \.self) { tier in
                                getColumn(for: tier)
                            }
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    private func getPerilNameColumn() -> some View {
        VStack(alignment: .leading) {
            hText("")
            //            ForEach(vm.perils[tier.name] ?? [], id: \.self) { peril in
            ForEach(mockPerils[mockTiers.first?.name ?? ""] ?? [], id: \.self) { peril in
                hText(peril.title, style: .label)
                    .fixedSize()
                    .frame(height: 32)
            }
        }
        .frame(width: 172, alignment: .leading)
    }

    @ViewBuilder
    private func getColumn(for tier: Tier) -> some View {
        VStack {
            hText(tier.name, style: .label)
                .foregroundColor(hTextColor.Opaque.black)
                .padding(.top, 7)
            //            ForEach(vm.perils[tier.name] ?? [], id: \.self) { peril in
            ForEach(mockPerils[tier.name] ?? [], id: \.self) { peril in
                getRowIcon(for: peril)
                    .frame(height: 32)
            }
        }
        .frame(width: 100, alignment: .center)
        .background(getColumnColor(for: tier))
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
    }

    @hColorBuilder
    private func getColumnColor(for tier: Tier) -> some hColor {
        //        if tier == vm.selectedTier {
        if tier.name == "Bas" {
            hHighlightColor.Green.fillOne
        } else {
            hBackgroundColor.clear
        }
    }

    private func getPillColor(for tier: Tier) -> PillColor {
        //            if tier == vm.selectedTier {
        if tier.name == "Bas" {
            return .green
        } else {
            return .grey(translucent: false)
        }
    }

    @ViewBuilder
    private func getRowIcon(for peril: Perils) -> some View {
        if let covered = peril.covered.first, covered != "" {
            //            hPill(text: covered, color: .blue, colorLevel: .two)
            Image(
                uiImage: hCoreUIAssets.checkmark.image
            )
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(getTextColor(for: peril))
        } else if !(peril.isDisabled) {
            Image(
                uiImage: hCoreUIAssets.checkmark.image
            )
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(getTextColor(for: peril))
        } else {
            Image(
                uiImage: hCoreUIAssets.minus.image
            )
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(getTextColor(for: peril))
        }
    }

    @hColorBuilder
    func getTextColor(for peril: Perils) -> some hColor {
        if peril.isDisabled {
            hFillColor.Opaque.secondary
        } else {
            hTextColor.Opaque.black
        }
    }
}

public class CompareTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var tiers: [Tier]
    @Published var extended = false

    @Published var perils: [String: [Perils]] = [:]
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
                            id: row.title,
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

                let mockTermsVersionsToCompare =
                    [
                        "SE_DOG_BASIC-20230330-HEDVIG-null",
                        "SE_DOG_STANDARD-20230330-HEDVIG-null",
                        "SE_DOG_PREMIUM-20230410-HEDVIG-null",
                    ]

                let productVariantComparisionData = try await service.compareProductVariants(
                    //                    termsVersion: termsVersionsToCompare
                    termsVersion: mockTermsVersionsToCompare
                )

                let columns = productVariantComparisionData.variantColumns
                let rows = productVariantComparisionData.rows
                let tierNames = columns.compactMap({ $0.displayNameTier })

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

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })

    let vm: CompareTierViewModel = .init(
        tiers: [
            .init(
                id: "tier1",
                name: "Bas",
                level: 0,
                quotes: [
                    .init(
                        id: "quote1",
                        quoteAmount: .init(amount: "220", currency: "SEK"),
                        quotePercentage: 0,
                        subTitle: nil,
                        premium: .init(amount: "220", currency: "SEK"),
                        displayItems: [],
                        productVariant: nil
                    )
                ],
                exposureName: "exposure name"
            )
        ],
        selectedTier: nil
    )

    vm.scrollableSegmentedViewModel = .init(
        pageModels: [
            .init(id: "Bas", title: "Bas"),
            .init(id: "Standard", title: "Standard"),
        ],
        currentId: "Bas"
    )

    vm.perils["Bas"] = [
        Perils(
            id: "peril1",
            title: "peril1",
            description: "description",
            color: nil,
            covered: ["30 000 kr"],
            isDisabled: false
        )
    ]

    return CompareTierScreen(vm: vm)
}
