import SwiftUI
import hCore

public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    @Published public var contracts: [ContractInfo]
    @Published var total: MonetaryAmount = .init(amount: "", currency: "")
    @Published var expandedContracts: [String] = []
    @Published var removedContracts: [String] = []
    public var onConfirmClick: () -> Void
    let isAddon: Bool
    let showNoticeCard: Bool
    @Published public var removeModel: QuoteSummaryViewModel.ContractInfo.RemoveModel? = nil

    func toggleContract(_ contract: ContractInfo) {
        if expandedContracts.contains(contract.id) {
            collapseContract(contract)
        } else {
            expandContract(contract)
        }
    }

    public func getRemovedContractsIds() -> [String] {
        removedContracts
    }

    private func expandContract(_ contract: ContractInfo) {
        expandedContracts.append(contract.id)
    }

    private func collapseContract(_ contract: ContractInfo) {
        expandedContracts.removeAll(where: { $0 == contract.id })
    }

    func removeContract(_ contractId: String) {
        expandedContracts.removeAll(where: { $0 == contractId })
        removedContracts.append(contractId)
        calculateTotal()
    }

    func addContract(_ contract: ContractInfo) {
        removedContracts.removeAll(where: { $0 == contract.id })
        calculateTotal()
    }

    func strikeThroughPriceType(_ contractId: String) -> StrikeThroughPriceType {
        if removedContracts.contains(contractId) {
            return .crossNewPrice
        }
        if isAddon {
            return .crossOldPrice
        }
        return .none
    }

    public struct ContractInfo: Identifiable {
        public var id: String
        let displayName: String
        let exposureName: String
        let newPremium: MonetaryAmount?
        let currentPremium: MonetaryAmount?
        let displayItems: [QuoteDisplayItem]
        let documents: [hPDFDocument]
        let onDocumentTap: (_ document: hPDFDocument) -> Void
        let insuranceLimits: [InsurableLimits]
        let typeOfContract: TypeOfContract?
        let shouldShowDetails: Bool
        let removeModel: RemoveModel?
        let isAddon: Bool
        public init(
            id: String,
            displayName: String,
            exposureName: String,
            newPremium: MonetaryAmount?,
            currentPremium: MonetaryAmount?,
            documents: [hPDFDocument],
            onDocumentTap: @escaping (_ document: hPDFDocument) -> Void,
            displayItems: [QuoteDisplayItem],
            insuranceLimits: [InsurableLimits],
            typeOfContract: TypeOfContract?,
            isAddon: Bool = false,
            removeModel: RemoveModel? = nil
        ) {
            self.id = id
            self.displayName = displayName
            self.exposureName = exposureName
            self.newPremium = newPremium
            self.currentPremium = currentPremium
            self.documents = documents
            self.onDocumentTap = onDocumentTap
            self.displayItems = displayItems
            self.insuranceLimits = insuranceLimits
            self.typeOfContract = typeOfContract
            shouldShowDetails = !(documents.isEmpty && displayItems.isEmpty && insuranceLimits.isEmpty)
            self.isAddon = isAddon
            self.removeModel = removeModel
        }

        public struct RemoveModel: Identifiable, Equatable {
            public var id: String
            let title: String
            let description: String
            let confirmButtonTitle: String
            let cancelRemovalButtonTitle: String

            public init(
                id: String,
                title: String,
                description: String,
                confirmButtonTitle: String,
                cancelRemovalButtonTitle: String
            ) {
                self.id = id
                self.title = title
                self.description = description
                self.confirmButtonTitle = confirmButtonTitle
                self.cancelRemovalButtonTitle = cancelRemovalButtonTitle
            }
        }
    }

    public init(
        contract: [ContractInfo],
        total: MonetaryAmount? = nil,
        isAddon: Bool? = false,
        onConfirmClick: (() -> Void)? = nil
    ) {
        contracts = contract
        self.isAddon = isAddon ?? false
        self.onConfirmClick = onConfirmClick ?? {}
        showNoticeCard = (contract.filter { !$0.isAddon }.count > 1 || isAddon ?? false)
        if let total = total {
            self.total = total
        } else {
            calculateTotal()
        }
    }

    func calculateTotal() {
        let totalValue = contracts.filter { !removedContracts.contains($0.id) }
            .reduce(0) { $0 + ($1.newPremium?.value ?? 0) }
        total = .init(amount: totalValue, currency: contracts.first?.newPremium?.currency ?? "")
    }
}

public struct QuoteSummaryScreen: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    private let showCoverageId = "showCoverageId"
    @State var spacingCoverage: CGFloat = 0
    @State var totalHeight: CGFloat = 0

    public init(
        vm: QuoteSummaryViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            hForm {
                VStack(spacing: .padding16) {
                    VStack(spacing: 0) {
                        ForEach(vm.contracts, id: \.id) { contract in
                            contractInfoView(for: contract, proxy: proxy)
                                .id(contract.id)
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    spacingCoverage = max(totalHeight - proxy.size.height, 0)
                                }
                                .onChange(of: proxy.size) { size in
                                    spacingCoverage = max(totalHeight - size.height, 0)
                                }
                        }
                    )
                }
            }
            .hButtonTakeFullWidth(true)
            .hFormAlwaysAttachToBottom {
                VStack(spacing: .padding8) {
                    if vm.showNoticeCard {
                        noticeComponent
                    }
                    buttonComponent(proxy: proxy)
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        totalHeight = proxy.size.height
                    }
                    .onChange(of: proxy.size) { size in
                        totalHeight = size.height
                    }
            }
        )
        .detent(
            item: $vm.removeModel,
            transitionType: .detent(style: [.height])
        ) { removeModel in
            InfoView(
                title: removeModel.title,
                description: removeModel.description,
                closeButtonTitle: removeModel.cancelRemovalButtonTitle,
                extraButton: ExtraButtonModel(
                    text: removeModel.confirmButtonTitle,
                    style: .primary
                ) { [weak vm] in
                    withAnimation(.easeInOut(duration: 0.4)) {
                        vm?.removeModel = nil
                        vm?.removeContract(removeModel.id)
                    }
                }
            )
        }
    }

    @ViewBuilder
    func contractInfoView(for contract: QuoteSummaryViewModel.ContractInfo, proxy: ScrollViewProxy) -> some View {
        let index = vm.expandedContracts.firstIndex(of: contract.id)
        let isExpanded = vm.isAddon ? true : (index != nil)

        if !contract.documents.isEmpty {
            contractContent(for: contract, proxy: proxy, isExpanded: isExpanded)
                .hAccessibilityWithoutCombinedElements
        } else {
            contractContent(for: contract, proxy: proxy, isExpanded: isExpanded)
        }
    }

    func contractContent(
        for contract: QuoteSummaryViewModel.ContractInfo,
        proxy: ScrollViewProxy,
        isExpanded: Bool
    ) -> some View {
        hSection {
            StatusCard(
                onSelected: {},
                mainContent: ContractInformation(
                    displayName: contract.displayName,
                    exposureName: vm.removedContracts.contains(contract.id) ? nil : contract.exposureName,
                    pillowImage: contract.typeOfContract?.pillowType.bgImage,
                    status: vm.removedContracts.contains(contract.id) ? L10n.contractStatusTerminated : nil
                ),
                title: nil,
                subTitle: nil,
                bottomComponent: {
                    bottomComponent(for: contract, proxy: proxy, isExpanded: isExpanded)
                }
            )
            .hCardWithoutSpacing
        }
        .padding(.top, .padding8)
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func bottomComponent(
        for contract: QuoteSummaryViewModel.ContractInfo,
        proxy: ScrollViewProxy,
        isExpanded: Bool
    ) -> some View {
        VStack(spacing: .padding16) {
            PriceField(
                newPremium: contract.newPremium,
                currentPremium: vm.removedContracts.contains(contract.id) ? nil : contract.currentPremium
            )
            .hWithStrikeThroughPrice(
                setTo: vm.strikeThroughPriceType(contract.id)
            )

            VStack(spacing: 0) {
                detailsView(for: contract, isExpanded: isExpanded)
                    .frame(height: isExpanded ? nil : 0, alignment: .top)
                    .clipped()
                    .accessibilityHidden(!isExpanded)
                if vm.removedContracts.contains(contract.id) {
                    hButton(
                        .medium,
                        .secondary,
                        content: .init(title: L10n.addonAddCoverage),
                        {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                vm.addContract(contract)
                            }
                        }
                    )
                    .transition(.scale)
                } else if contract.shouldShowDetails, !vm.isAddon {
                    hButton(
                        .medium,
                        .secondary,
                        content: .init(
                            title: vm.expandedContracts.firstIndex(of: contract.id) != nil
                                ? L10n.ClaimStatus.ClaimHideDetails.button : L10n.ClaimStatus.ClaimDetails.button
                        ),
                        {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                vm.toggleContract(contract)
                                Task { [weak vm] in
                                    guard let vm else { return }
                                    try await Task.sleep(nanoseconds: 200_000_000)
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        if vm.expandedContracts.contains(contract.id) {
                                            proxy.scrollTo(contract.id, anchor: .top)
                                        }
                                    }
                                }
                            }
                        }
                    )
                    .hWithTransition(.scale)
                }
            }
        }
    }

    private var noticeComponent: some View {
        hSection {
            InfoCard(
                text:
                    vm.isAddon
                    ? L10n.addonFlowSummaryInfoText
                    : L10n.changeAddressOtherInsurancesInfoText,
                type: .info
            )
        }
        .sectionContainerStyle(.transparent)
    }

    func detailsView(for contract: QuoteSummaryViewModel.ContractInfo, isExpanded: Bool) -> some View {
        VStack(spacing: .padding16) {
            hRowDivider()
                .hWithoutHorizontalPadding([.divider])

            if !contract.displayItems.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.summaryScreenOverview)
                        .accessibilityAddTraits(.isHeader)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(contract.displayItems, id: \.displayTitle) { item in
                        rowItem(for: item)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityRemoveTraits(.isHeader)
            }

            if !contract.insuranceLimits.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    hText(L10n.summaryScreenCoverage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    ZStack {
                        VStack {
                            ForEach(contract.insuranceLimits, id: \.limit) { limit in
                                let displayItem: QuoteDisplayItem = .init(
                                    title: limit.label,
                                    value: limit.limit ?? "",
                                    id: limit.id
                                )
                                rowItem(for: displayItem)
                            }
                        }
                        hText(" ")
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityRemoveTraits(.isHeader)
            }

            if !contract.documents.isEmpty {
                VStack(alignment: .leading, spacing: .padding4) {
                    hText(L10n.confirmationScreenDocumentTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(contract.documents, id: \.displayName) { document in
                        documentItem(for: document)
                            .background(hSurfaceColor.Opaque.primary)
                            .accessibilityElement(children: .combine)
                            .onTapGesture {
                                contract.onDocumentTap(document)
                            }
                            .accessibilityAction {
                                contract.onDocumentTap(document)
                            }
                    }
                }
            }
            if let removeModel = contract.removeModel, !vm.removedContracts.contains(contract.id),
                isExpanded
            {
                hButton(
                    .medium,
                    .ghost,
                    content: .init(title: L10n.General.remove),
                    {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            vm.removeModel = removeModel
                        }
                    }
                )
                .hWithTransition(.scale)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusM)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                }
                .padding(.bottom, .padding8)
            }
        }
        .padding(.bottom, (isExpanded && !vm.isAddon) ? .padding16 : 0)
    }

    func rowItem(for displayItem: QuoteDisplayItem) -> some View {
        HStack(alignment: .top) {
            hText(displayItem.displayTitle)
            Spacer()

            if let oldValue = displayItem.displayValueOld, oldValue != displayItem.displayValue {
                if #available(iOS 16.0, *) {
                    hText(oldValue)
                        .strikethrough()
                        .accessibilityLabel(L10n.voiceoverCurrentValue + oldValue)
                } else {
                    hText(oldValue)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                        .accessibilityLabel(L10n.voiceoverCurrentValue + oldValue)
                }
            }

            hText(displayItem.displayValue)
                .multilineTextAlignment(.trailing)
                .accessibilityLabel(
                    displayItem.displayValueOld != nil && displayItem.displayValueOld != displayItem.displayValue
                        ? L10n.voiceoverNewValue + displayItem.displayValue : displayItem.displayValue
                )
        }
        .foregroundColor(hTextColor.Translucent.secondary)
    }

    func documentItem(for document: hPDFDocument) -> some View {
        HStack {
            hAttributedTextView(
                text: AttributedPDF().attributedPDFString(for: document.displayName),
                useSecondaryColor: true
            )
            .padding(.horizontal, -6)
            Spacer()
            hCoreUIAssets.arrowNorthEast.view
                .resizable()
                .frame(width: 24, height: 24)
        }
        .foregroundColor(hTextColor.Translucent.secondary)
    }

    private let whatIsCoveredBgColorScheme: some hColor = hColorScheme.init(
        light: hBlueColor.blue100,
        dark: hBlueColor.blue900
    )

    private func buttonComponent(proxy _: ScrollViewProxy) -> some View {
        hSection {
            VStack(spacing: .padding16) {
                HStack {
                    hText(L10n.tierFlowTotal)
                    Spacer()

                    let amount = vm.total

                    if vm.isAddon {
                        VStack(alignment: .trailing, spacing: 0) {
                            if amount.value >= 0 {
                                hText(L10n.addonFlowPriceLabel(amount.formattedAmount))
                            } else {
                                hText(amount.formattedAmountPerMonth)
                            }
                            hText(L10n.addonFlowSummaryPriceSubtitle, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    } else {
                        hText(amount.formattedAmountPerMonth)
                    }
                }
                .accessibilityElement(children: .combine)
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(
                            title: vm.isAddon ? L10n.addonFlowSummaryConfirmButton : L10n.changeAddressAcceptOffer
                        ),
                        { [weak vm] in
                            vm?.onConfirmClick()
                        }
                    )
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    var chatComponent: some View {
        VStack(spacing: 0) {
            hText(L10n.changeAddressNoFind, style: .body1)
            Spacing(height: 16)

            hButton(
                .small,
                .primary,
                content: .init(title: L10n.openChat),
                {
                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                }
            )
            .fixedSize()
        }
    }
}

public struct QuoteDisplayItem: Identifiable, Equatable, Sendable {
    public let id: String?
    let displayTitle: String
    let displayValue: String
    let displayValueOld: String?

    public init(
        title displayTitle: String,
        value displayValue: String,
        displayValueOld: String? = nil,
        id: String? = nil
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
        self.displayValueOld = displayValueOld
        self.id = id
    }
}

public struct FAQ: Codable, Equatable, Hashable, Sendable {
    public var title: String
    public var description: String?

    public init(
        title: String,
        description: String?
    ) {
        self.title = title
        self.description = description
    }
}

#Preview(body: {
    let documents: [hPDFDocument] = [
        .init(displayName: "document 1", url: "https//hedvig.com", type: .generalTerms),
        .init(displayName: "document 2", url: "https//hedvig.com", type: .preSaleInfo),
    ]
    let vm = QuoteSummaryViewModel(
        contract: [
            .init(
                id: "id1",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { _ in },
                displayItems: [
                    .init(title: "Limits", value: "mockLimits mockLimits long long long name"),
                    .init(title: "Documents", value: "documents"),
                    .init(title: "FAQ", value: "mockFAQ"),
                ],
                insuranceLimits: [],
                typeOfContract: .seApartmentBrf
            ),
            .init(
                id: "id2",
                displayName: "Travel addon",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: nil,
                documents: documents,
                onDocumentTap: { _ in },
                displayItems: [
                    .init(title: "Limits", value: "mockLimits"),
                    .init(title: "Documents", value: "documents"),
                    .init(title: "FAQ", value: "mockFAQ"),
                ],
                insuranceLimits: [
                    .init(label: "label", limit: "limit", description: "description"),
                    .init(label: "label2", limit: "limit2", description: "description2"),
                    .init(label: "label3", limit: "limit3", description: "description3"),
                ],
                typeOfContract: nil,
                isAddon: true,
                removeModel: .init(
                    id: "id2",
                    title: "Remove Travel Insurance Plus",
                    description:
                        "By removing this extended coverage, your insurance will no longer include extra protection while traveling.",
                    confirmButtonTitle: "Remove Travel Insurance Plus",
                    cancelRemovalButtonTitle: "Keep current coverage"
                )
            ),
            .init(
                id: "id3",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { _ in },
                displayItems: [],
                insuranceLimits: [
                    .init(label: "label", limit: "limit", description: "description"),
                    .init(label: "label2", limit: "limit2", description: "description2"),
                    .init(label: "label3", limit: "limit3", description: "description3"),
                ],
                typeOfContract: .seAccident
            ),
            .init(
                id: "id4",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: [],
                onDocumentTap: { _ in },
                displayItems: [],
                insuranceLimits: [],
                typeOfContract: .seAccident
            ),
            .init(
                id: "id5",
                displayName: "Dog",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: [],
                onDocumentTap: { _ in },
                displayItems: [],
                insuranceLimits: [],
                typeOfContract: .seDogStandard
            ),
        ],
        onConfirmClick: {}
    )

    return QuoteSummaryScreen(vm: vm)
})

private struct EnvironmentHAccessibilityWithoutCombinedElements: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hAccessibilityWithoutCombinedElements: Bool {
        get { self[EnvironmentHAccessibilityWithoutCombinedElements.self] }
        set { self[EnvironmentHAccessibilityWithoutCombinedElements.self] = newValue }
    }
}

extension View {
    public var hAccessibilityWithoutCombinedElements: some View {
        environment(\.hAccessibilityWithoutCombinedElements, true)
    }
}
