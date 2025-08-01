import SwiftUI
import hCore
import hCoreUI

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @SwiftUI.Environment(\.colorScheme) var colorSchema
    @State var plusImage = hCoreUIAssets.plus.image.getImageFor(style: .body1)

    init(
        vm: CompareTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        succesView.loading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            vm.productVariantComparision()
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonAction: {
                                changeTierNavigationVm.router.dismiss()
                            }
                        )
                )
            )
    }

    private func comparisionView(for tierName: String) -> some View {
        hSection(vm.getPerils(for: tierName), id: \.title) { peril in
            perilRow(for: peril)
        }
        .sectionContainerStyle(.transparent)
        .padding(.bottom, .padding24)
        .hWithoutHorizontalPadding([.row, .divider])
        .accessibilityHint(L10n.tierFlowCoverageLabel + tierName)
    }

    private func perilRow(for peril: Perils) -> some View {
        hRow {
            HStack(alignment: .top, spacing: .padding4) {
                Group {
                    Text(peril.title)
                        + Text(plusImage.renderingMode(.template))
                        .foregroundColor(
                            hFillColor.Translucent.secondary.colorFor(colorSchema == .light ? .light : .dark, .base)
                                .color
                        )
                }
                .modifier(hFontModifier(style: .body1))
                .fixedSize(horizontal: false, vertical: true)
                Spacer()
                peril.getRowDescription
            }
        }
        .modifier(CompareOnRowTap(currentPeril: peril))
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverTierComparisionClick(peril.title))
    }

    @ViewBuilder
    private var succesView: some View {
        hForm {
            if let scrollableSegmentedViewModel = vm.scrollableSegmentedViewModel {
                ScrollableSegmentedView(
                    vm: scrollableSegmentedViewModel,
                    headerBottomPadding: .padding8,
                    contentFor: { id in
                        comparisionView(for: id)
                    }
                )
                .padding(.top, .padding24)
            }
        }
        .hFormTitle(
            title: .init(
                .none,
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
}

struct CompareOnRowTap: ViewModifier {
    let currentPeril: Perils
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        currentPeril: Perils
    ) {
        self.currentPeril = currentPeril
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                changeTierNavigationVm.isInsurableLimitPresented = .init(
                    label: currentPeril.title,
                    description: currentPeril.description
                )
            }
    }
}

@MainActor
class CompareTierViewModel: ObservableObject {
    private let service = ChangeTierService()
    @Published var viewState: ProcessingState = .loading
    let tiers: [Tier]
    @Published var selectedPeril: Perils?
    @Published var perils: [(String, [Perils])] = []
    @Published var scrollableSegmentedViewModel: ScrollableSegmentedViewModel?

    init(
        tiers: [Tier]
    ) {
        self.tiers = tiers
        productVariantComparision()
    }

    private func getPerils(
        tierNames: [String]?,
        rows: [ProductVariantComparison.ProductVariantComparisonRow]?
    ) -> [(String, [Perils])] {
        var tempPerils: [(String, [Perils])] = []
        var index = 0

        tierNames?
            .forEach { tierName in
                let cells = rows?
                    .map { row in
                        let cellForIndex = row.cells[index]
                        return Perils(
                            id: row.title,
                            title: row.title,
                            description: row.description,
                            color: row.colorCode,
                            covered: [cellForIndex.coverageText ?? ""],
                            isDisabled: !cellForIndex.isCovered
                        )
                    }

                tempPerils.append((tierName, cells ?? []))
                index = index + 1
            }
        return tempPerils
    }

    func productVariantComparision() {
        withAnimation {
            viewState = .loading
        }
        Task { @MainActor in
            do {
                var termsVersionsToCompare: [String] = []
                for tier in tiers {
                    for quote in tier.quotes {
                        if let termsVersion = quote.productVariant?.termsVersion,
                            !termsVersionsToCompare.contains(termsVersion)
                        {
                            termsVersionsToCompare.append(termsVersion)
                        }
                    }
                }

                let productVariantComparisionData = try await service.compareProductVariants(
                    termsVersion: termsVersionsToCompare
                )

                let rows = productVariantComparisionData.rows
                let namesOfTiers = productVariantComparisionData.variantColumns.compactMap(\.displayNameTier)
                self.perils = getPerils(tierNames: namesOfTiers, rows: rows)
                scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
                    pageModels: namesOfTiers.map { .init(id: $0, title: $0) }
                )
                withAnimation {
                    viewState = .success
                }
            } catch {
                withAnimation {
                    self.viewState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }

    func getPerils(for tierName: String) -> [Perils] {
        perils.first(where: { $0.0 == tierName })?.1.filter { !$0.isDisabled } ?? []
    }
}

extension Perils {
    @ViewBuilder @MainActor
    var getRowDescription: some View {
        Group {
            if let covered = self.covered.first, covered != "" {
                ZStack {
                    hText(covered)
                    hText(" ")
                }
            } else if !self.isDisabled {
                Image(
                    uiImage: hCoreUIAssets.checkmark.image
                )
                .resizable()
                .frame(width: 24, height: 24)
            }
        }
        .foregroundColor(hFillColor.Opaque.secondary)
        .frame(minWidth: 150, alignment: .trailing)
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
                basePremium: .init(amount: "220", currency: "SEK"),
                displayItems: [],
                productVariant: nil,
                addons: []
            )
        ],
        exposureName: "Standard"
    )

    let premiumTier = Tier(
        id: "PREMIUM",
        name: "Premium",
        level: 0,
        quotes: [
            .init(
                id: "quote1",
                quoteAmount: .init(amount: "220", currency: "SEK"),
                quotePercentage: 0,
                subTitle: nil,
                basePremium: .init(amount: "220", currency: "SEK"),
                displayItems: [],
                productVariant: nil,
                addons: []
            )
        ],
        exposureName: "exposure name"
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
                        basePremium: .init(amount: "220", currency: "SEK"),
                        displayItems: [],
                        productVariant: nil,
                        addons: []
                    )
                ],
                exposureName: "exposure name"
            ),
            standardTier,
            premiumTier,
        ]
    )

    return CompareTierScreen(vm: vm)
        .environmentObject(
            ChangeTierNavigationViewModel(
                changeTierContractsInput: .init(source: .changeTier, contracts: []),
                onChangedTier: {}
            )
        )
}

extension UIImage {
    fileprivate func getImageFor(style: HFontTextStyle) -> Image {
        let height = 24 * style.multiplier
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: height, height: height), format: renderFormat)
        let newImage = renderer.image {
            _ in
            self.draw(in: CGRect(x: 0, y: height * 0.2, width: height, height: height))
        }

        return Image(uiImage: newImage)
    }
}
