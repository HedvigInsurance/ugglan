import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension Perils {
    @ViewBuilder @MainActor
    var getRowDescription: some View {
        Group {
            if let covered = self.covered.first, covered != "" {
                hText(covered)
            } else if !self.isDisabled {
                Image(
                    uiImage: hCoreUIAssets.checkmark.image
                )
                .resizable()
                .frame(width: 24, height: 24)
            }
        }
        .foregroundColor(hFillColor.Opaque.secondary)
    }
}

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @State var scrollableSegmentedViewModel: ScrollableSegmentedViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(
        vm: CompareTierViewModel
    ) {
        self.vm = vm
        scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
            pageModels: vm.tiers.map({ .init(id: $0.id, title: $0.name) })
        )
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
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                changeTierNavigationVm.router.dismiss()
                            }
                        )
                )
            )
    }

    private func comparisionView(for tierName: String) -> some View {
        VStack {
            hSection(vm.getPerils(for: tierName), id: \.title) { peril in
                perilRow(for: peril)
            }
            .sectionContainerStyle(.transparent)
            .hSectionWithoutHorizontalPadding
        }
    }

    private func perilRow(for peril: Perils) -> some View {
        hRow {
            HStack(alignment: .bottom, spacing: .padding4) {
                hText(peril.title)
                Image(uiImage: hCoreUIAssets.plus.image)
                    .foregroundColor(hFillColor.Translucent.secondary)
                Spacer()
                peril.getRowDescription
            }
        }
        .modifier(CompareOnRowTap(currentPeril: peril, vm: vm))
    }

    @ViewBuilder
    private var succesView: some View {
        hForm {
            ScrollableSegmentedView(
                vm: scrollableSegmentedViewModel,
                contentFor: { id in
                    comparisionView(for: vm.tiers.first(where: { $0.id == id })?.name ?? "")
                }
            )
            .padding(.top, 20)
            .padding(.horizontal, horizontalSizeClass == .regular ? .padding60 : 0)
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
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        currentPeril: Perils,
        vm: CompareTierViewModel
    ) {
        self.currentPeril = currentPeril
        self.vm = vm
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                changeTierNavigationVm.isInsurableLimitPresented = .init(
                    label: currentPeril.title,
                    limit: "",
                    description: currentPeril.description
                )
            }
            .onLongPressGesture(minimumDuration: 0.1) {
                if #available(iOS 18.0, *) {
                    withAnimation {
                        vm.selectedPeril = currentPeril
                    }
                }
            } onPressingChanged: { isPressing in
                if !isPressing {
                    withAnimation {
                        vm.selectedPeril = nil
                    }
                }
            }
            .background(getRowColor(for: currentPeril))
    }

    @hColorBuilder
    private func getRowColor(for peril: Perils) -> some hColor {
        if peril.title == vm.selectedPeril?.title {
            hButtonColor.Ghost.hover
        } else {
            hBackgroundColor.clear
        }
    }
}

@MainActor
class CompareTierViewModel: ObservableObject {
    private let service = ChangeTierService()
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var currentTier: Tier?
    @Published var tiers: [Tier]
    @Published var selectedPeril: Perils?
    @Published var perils: [(String, [Perils])] = []

    init(
        tiers: [Tier],
        selectedTier: Tier? = nil,
        currentTier: Tier?
    ) {
        self.selectedTier = selectedTier
        self.currentTier = currentTier
        self.tiers = tiers
        self.productVariantComparision()
    }

    private func getPerils(
        tierNames: [String]?,
        rows: [ProductVariantComparison.ProductVariantComparisonRow]?
    ) -> [(String, [Perils])] {
        var tempPerils: [(String, [Perils])] = []
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

                tempPerils.append((tierName, cells ?? []))
                index = index + 1
            })
        return tempPerils
    }

    func productVariantComparision() {
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

                let rows = productVariantComparisionData.rows
                let tierNames = tiers.compactMap({ $0.name })

                self.perils = getPerils(tierNames: tierNames, rows: rows)
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

    func getPerils(for tierName: String) -> [Perils] {
        perils.first(where: { $0.0 == tierName })?.1.filter({ !$0.isDisabled }) ?? []
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
        ],
        selectedTier: standardTier,
        currentTier: standardTier
    )

    return CompareTierScreen(vm: vm)
}
