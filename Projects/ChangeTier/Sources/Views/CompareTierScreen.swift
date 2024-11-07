import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State var offset: CGPoint = .zero

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

    private var scrollContent: some View {
        HStack(spacing: 0) {
            ForEach(vm.tiers, id: \.self) { tier in
                getColumn(for: tier).id("column " + tier.id)
            }
        }
    }

    @ViewBuilder
    var succesView: some View {
        hForm {
            HStack(spacing: 0) {
                ZStack {
                    shadowDividerView
                    perilTitleColumn
                        .frame(width: horizontalSizeClass == .regular ? 190 : 140, alignment: .leading)
                }
                .zIndex(2)

                Divider()
                    .frame(minHeight: 1)
                    .overlay(hBorderColor.secondary)
                    .padding(.top, 32)
                    .opacity(offset.x <= .zero ? 1 : 0)
                ScrollViewReader { scrollView in
                    ScrollView(
                        [.horizontal],
                        showsIndicators: false,
                        content: {
                            scrollContent
                        }
                    )
                    .modifier(TrackingOffsetModifier(offset: $offset))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.spring(duration: 2)) {
                                scrollView.scrollTo("column " + vm.tiers[1].id, anchor: .leading)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(duration: 2)) {
                                    scrollView.scrollTo("column " + vm.tiers[0].id, anchor: .leading)
                                }
                            }
                        }
                    }
                }
                .zIndex(1)
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding
            .padding(.top, .padding16)
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

    @ViewBuilder
    private var shadowDividerView: some View {
        Rectangle()
            .fill(hBackgroundColor.black)
            .padding(.top, 32)
            .frame(width: horizontalSizeClass == .regular ? 200 : 140, alignment: .leading)
            .shadow(color: Color.black.opacity(0.05), radius: offset.x > .zero ? 5 : 0, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.1), radius: offset.x > .zero ? 1 : 0, x: 0, y: 2)
            .mask {
                Rectangle()
                    .offset(x: horizontalSizeClass == .regular ? 110 : 80, y: 10)
                    .frame(width: 20)
            }
    }

    @ViewBuilder
    private var perilTitleColumn: some View {
        VStack(alignment: .leading) {
            hText("", style: .label)
                .padding(.top, 11)
            let firstTier = vm.tiers.first?.name ?? ""

            hSection(vm.perils[firstTier] ?? [], id: \.self) { peril in
                hRow {
                    hText(peril.title, style: .label)
                        .frame(height: .padding40, alignment: .center)
                        .frame(maxWidth: 124, alignment: .leading)
                }
                .verticalPadding(0)
                .frame(width: horizontalSizeClass == .regular ? 135 : 124)
                .modifier(CompareOnRowTap(currentPeril: peril, vm: vm))
            }
            .hWithoutDividerPadding
        }
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
                    .dividerInsets(.leading, tier == vm.tiers.first ? -100 : 0)
                    .modifier(CompareOnRowTap(currentPeril: peril, vm: vm))
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
                let descriptionText = vm.getDescriptionText

                changeTierNavigationVm.isInsurableLimitPresented = .init(
                    label: currentPeril.title,
                    limit: "",
                    description: descriptionText(currentPeril)
                )
            }
            .onLongPressGesture {
                withAnimation {
                    vm.selectedPeril = currentPeril
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

public class CompareTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ProcessingState = .loading
    @Published var selectedTier: Tier?
    @Published var tiers: [Tier]
    @Published var selectedPeril: Perils?
    @Published var perils: [String: [Perils]] = [:]

    init(
        tiers: [Tier],
        selectedTier: Tier? = nil
    ) {
        self.selectedTier = selectedTier
        self.tiers = tiers
        self.productVariantComparision()
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

    public func productVariantComparision() {
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

    func getDescriptionText(for currentPeril: Perils) -> String {
        var allMatchingPerils: [String: Perils] = [:]
        perils.forEach { tierName, allTierNamePerils in
            allTierNamePerils.forEach { peril in
                if currentPeril.title == peril.title {
                    allMatchingPerils[tierName] = peril
                }
            }
        }

        var coverageTexts: [String] = []
        allMatchingPerils.forEach { tierName, peril in
            if let coverageText = peril.covered.first, coverageText != "" {
                coverageTexts.append(tierName + ": " + coverageText)
            }
        }

        var coverageTextDisplayString: String = ""
        coverageTexts.forEach { text in
            coverageTextDisplayString += "\n" + text
        }

        if coverageTextDisplayString != "" {
            return currentPeril.description + "\n" + coverageTextDisplayString
        }
        return currentPeril.description
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
