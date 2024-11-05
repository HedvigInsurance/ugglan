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

    @ViewBuilder
    var succesView: some View {
        hForm {
            HStack(spacing: 0) {
                getPerilNameColumn()
                    .frame(width: 140, alignment: .leading)

                Divider()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(vm.tiers, id: \.self) { tier in
                            getColumn(for: tier)
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .hWithoutDividerPadding
            .hWithoutHorizontalPadding
            .padding(.top, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .body2,
                L10n.tierComparisonTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .body2,
                L10n.tierComparisonSubtitle
            )
        )
    }

    @ViewBuilder
    private func getPerilNameColumn() -> some View {
        VStack(alignment: .leading) {
            hText("", style: .label)
                .padding(.top, 11)
            let firstTier = vm.tiers.first?.name ?? ""

            hSection(vm.perils[firstTier] ?? [], id: \.self) { peril in
                hRow {
                    hText(peril.title, style: .label)
                        .frame(height: .padding40, alignment: .center)
                        .onTapGesture {

                            let descriptionText = getDescriptionText(for: peril)

                            changeTierNavigationVm.isInsurableLimitPresented = .init(
                                label: peril.title,
                                limit: "",
                                description: descriptionText
                            )
                        }
                }
                .verticalPadding(0)
                .frame(width: 124)
            }
        }
    }

    private func getDescriptionText(for peril: Perils) -> String {
        if let coverageText = peril.covered.first, coverageText != "" {
            return peril.description + "\n\n" + coverageText
        }
        return peril.description
    }

    @ViewBuilder
    private func getColumn(for tier: Tier) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: .cornerRadiusXS)
                .fill(getColumnColor(for: tier))
                .frame(width: 100, alignment: .center)

            VStack(alignment: .center) {
                hText(tier.name, style: .label)
                    .foregroundColor(getTierNameColor(for: tier))
                    .padding(.top, 7)

                hSection(vm.perils[tier.name] ?? [], id: \.self) { peril in
                    hRow {
                        getRowIcon(for: peril, tier: tier)
                            .frame(height: .padding40, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .verticalPadding(0)
                }
                .hSectionWithoutHorizontalPadding
            }
        }
    }

    @hColorBuilder
    private func getColumnColor(for tier: Tier) -> some hColor {
        if tier == vm.selectedTier {
            hHighlightColor.Green.fillOne
        } else {
            hBackgroundColor.clear
        }
    }

    @hColorBuilder
    private func getTierNameColor(for tier: Tier) -> some hColor {
        if tier == vm.selectedTier {
            hTextColor.Opaque.black
        } else {
            hTextColor.Opaque.primary
        }
    }

    @ViewBuilder
    private func getRowIcon(for peril: Perils, tier: Tier) -> some View {
        Group {
            if !(peril.isDisabled) {
                Image(
                    uiImage: hCoreUIAssets.checkmark.image
                )
                .resizable()
            } else {
                Image(
                    uiImage: hCoreUIAssets.minus.image
                )
                .resizable()
            }
        }
        .frame(width: 24, height: 24)
        .foregroundColor(getIconColor(for: peril, tier: tier))
    }

    @hColorBuilder
    func getIconColor(for peril: Perils, tier: Tier) -> some hColor {
        if peril.isDisabled {
            hFillColor.Opaque.disabled
        } else if tier == vm.selectedTier {
            hFillColor.Opaque.black
        } else {
            hFillColor.Opaque.secondary
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

                let productVariantComparisionData = try await service.compareProductVariants(
                    termsVersion: termsVersionsToCompare
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

    let standardTier = Tier(
        id: "STANDARD",
        name: "Standard",
        level: 2,
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
        exposureName: "Standard"
    )

    let vm: CompareTierViewModel = .init(
        tiers: [
            .init(
                id: "BAS",
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
            ),
            standardTier,
            .init(
                id: "PREMIUM",
                name: "Premium",
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
            ),
        ],
        selectedTier: standardTier
    )

    return CompareTierScreen(vm: vm)
}
