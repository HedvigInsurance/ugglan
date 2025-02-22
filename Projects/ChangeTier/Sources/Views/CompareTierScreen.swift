import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CompareTierScreen: View {
    @ObservedObject private var vm: CompareTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @State var shadowIntensity: CGFloat = 0
    @State var shouldShowDivider = true
    @ObservedObject var tracingOffsetVm = TracingOffsetViewModel()
    private let setOffsetVm = SetOffsetViewModel()

    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @SwiftUI.Environment(\.colorScheme) private var colorScheme
    @State private var leftColumnWidth: CGFloat = 0

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
            ForEach(vm.tiers, id: \.id) { tier in
                Column(
                    tier: tier,
                    selectedTier: vm.selectedTier,
                    perils: vm.getPerils(for: tier.name),
                    vm: vm
                )
            }
            Spacing(height: Float(horizontalSizeClass == .regular ? CGFloat.padding64 : CGFloat.padding16))
        }
    }

    @ViewBuilder
    var succesView: some View {
        hForm {
            ZStack {
                HStack(spacing: 0) {
                    ZStack {
                        shadowDividerView
                        perilTitleColumn
                    }
                    .frame(width: leftColumnWidth)
                    .zIndex(2)
                    if shouldShowDivider {
                        Rectangle()
                            .fill(hBorderColor.secondary)
                            .frame(width: 1)
                            .padding(.top, 32)
                    }

                    ScrollViewReader { scrollView in
                        ScrollView(
                            [.horizontal],
                            showsIndicators: false,
                            content: {
                                scrollContent
                            }
                        )
                        .modifier(TrackingOffsetModifier(vm: tracingOffsetVm))
                        .modifier(SetOffsetModifier(vm: setOffsetVm))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak setOffsetVm, weak vm] in
                                guard let setOffsetVm = setOffsetVm, let vm = vm else { return }
                                if vm.tiers.first == vm.selectedTier {
                                    setOffsetVm.animate(
                                        with: .init(duration: 1, damping: 0.6, offset: .init(x: 60, y: 0))
                                    )
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        setOffsetVm.animate(with: .init(duration: 1, damping: 0.6, offset: .zero))
                                    }
                                } else {
                                    if let selectedTierIndex = vm.tiers.firstIndex(where: { $0 == vm.selectedTier }) {
                                        let columnWidth = 108
                                        let offset = selectedTierIndex * columnWidth - columnWidth / 2
                                        setOffsetVm.animate(
                                            with: .init(duration: 1, damping: 0.6, offset: .init(x: offset, y: 0))
                                        )
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

                //added to measure current left size - aprox 140 on default text size
                hText("hhhhhhhhhhhhhhhhh", style: .label)
                    .foregroundColor(.clear)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    leftColumnWidth = min(proxy.size.width, 300)
                                }
                                .onChange(of: proxy.size) { newValue in
                                    leftColumnWidth = min(proxy.size.width, 300)
                                }
                        }
                    }
            }
            .padding(.leading, horizontalSizeClass == .regular ? .padding60 : .padding16)
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
        .onChange(of: tracingOffsetVm.currentOffset) { _ in
            setShadowAndDivider()
        }
        .onChange(of: colorScheme) { _ in
            setShadowAndDivider()
        }
        .onAppear {
            setShadowAndDivider()
        }
    }

    private func setShadowAndDivider() {
        withAnimation {
            shadowIntensity = {
                guard colorScheme == .light else { return 0 }
                let absoluteValue = min(max(tracingOffsetVm.currentOffset.x, 2), 5)  // goes from 2 - 5
                let relativeValue = absoluteValue / 5
                return relativeValue
            }()
            shouldShowDivider = colorScheme == .dark
        }
    }

    private var shadowDividerView: some View {
        VStack(spacing: 0) {
            hText(" ", style: .label)
                .padding(.top, 7)
            Rectangle()
                .fill(hBackgroundColor.black)
                .frame(width: leftColumnWidth, alignment: .leading)
                .shadow(
                    color: shadowColor.opacity(0.05),
                    radius: shadowIntensity * 5,
                    x: 0,
                    y: 4
                )
                .shadow(
                    color: shadowColor.opacity(0.1),
                    radius: shadowIntensity * 1,
                    x: 0,
                    y: 2
                )
                .mask {
                    Rectangle()
                        .offset(x: leftColumnWidth, y: 0)
                        .padding(.vertical, -20)
                        .frame(width: leftColumnWidth)
                }
        }
    }

    private var shadowColor: Color {
        hTextColor.Opaque.primary.colorFor(colorScheme == .light ? .light : .dark, .base).color
    }

    private var perilTitleColumn: some View {
        VStack(alignment: .leading) {
            hText(" ", style: .label)
                .padding(.top, 7)
            let firstTier = vm.tiers.first?.name ?? ""

            hSection(vm.getPerils(for: firstTier), id: \.self) { peril in
                hRow {
                    ZStack {
                        hText(peril.title, style: .label)
                            .frame(height: .padding40, alignment: .center)
                            .lineLimit(1)
                    }
                }
                .verticalPadding(0)
                .frame(width: leftColumnWidth)
                .modifier(CompareOnRowTap(currentPeril: peril, vm: vm))
            }
            .hWithoutDividerPadding
            .hSectionWithoutHorizontalPadding
        }
        .fixedSize()
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

                let columns = productVariantComparisionData.variantColumns
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

    func getDescriptionText(for currentPeril: Perils) -> String {
        var allMatchingPerils: [(String, Perils)] = []
        perils.forEach { tierName, allTierNamePerils in
            allTierNamePerils.forEach { peril in
                if currentPeril.title == peril.title {
                    allMatchingPerils.append((tierName, peril))
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

    func getPerils(for tierName: String) -> [Perils] {
        perils.first(where: { $0.0 == tierName })?.1 ?? []
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
