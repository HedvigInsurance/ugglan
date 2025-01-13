import SwiftUI
import hCore
import hGraphQL

public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    let contracts: [ContractInfo]
    let total: MonetaryAmount
    let onConfirmClick: () -> Void
    let isAddon: Bool
    let showNoticeCard: Bool

    public struct ContractInfo: Identifiable {
        public let id: String
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
        let onInfoClick: (() -> Void)?

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
            onInfoClick: (() -> Void)? = nil
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
            self.shouldShowDetails = !(documents.isEmpty && displayItems.isEmpty && insuranceLimits.isEmpty)
            self.onInfoClick = onInfoClick
        }
    }

    public init(
        contract: [ContractInfo],
        total: MonetaryAmount,
        isAddon: Bool? = false,
        onConfirmClick: @escaping () -> Void
    ) {
        self.contracts = contract
        self.total = total
        self.isAddon = isAddon ?? false
        self.onConfirmClick = onConfirmClick
        self.showNoticeCard = (contracts.count > 1 || isAddon ?? false)
    }
}

public struct QuoteSummaryScreen: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    private let showCoverageId = "showCoverageId"
    @State var selectedContracts: [String] = []
    @State var spacingCoverage: CGFloat = 0
    @State var totalHeight: CGFloat = 0
    let multiplier = HFontTextStyle.body1.multiplier

    public init(
        vm: QuoteSummaryViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            hForm {
                VStack(spacing: .padding16 * multiplier) {
                    VStack(spacing: .padding8 * multiplier) {
                        ForEach(vm.contracts, id: \.id) { contract in
                            contractInfoView(for: contract)
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
            .hFormAttachToBottom {
                VStack {
                    if vm.showNoticeCard {
                        noticeComponent
                            .padding(.top, .padding16)
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
    }

    func contractInfoView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        hSection {
            StatusCard(
                onSelected: {},
                mainContent: ContractInformation(
                    displayName: contract.displayName,
                    exposureName: contract.exposureName,
                    pillowImage: contract.typeOfContract?.pillowType.bgImage,
                    onInfoClick: contract.onInfoClick
                ),
                title: nil,
                subTitle: nil,
                bottomComponent: {
                    VStack(spacing: .padding16 * multiplier) {
                        PriceField(
                            newPremium: contract.newPremium,
                            currentPremium: contract.currentPremium
                        )
                        .hWithStrikeThroughPrice(setTo: vm.isAddon ? true : false)

                        let index = selectedContracts.firstIndex(of: contract.id)
                        let isExpanded = vm.isAddon ? true : (index != nil)
                        VStack(spacing: 0) {
                            detailsView(for: contract, isExpanded: isExpanded)
                                .frame(height: isExpanded ? nil : 0, alignment: .top)
                                .clipped()

                            if contract.shouldShowDetails && !vm.isAddon {
                                hButton.MediumButton(
                                    type: .secondary
                                ) {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        let index = selectedContracts.firstIndex(of: contract.id)
                                        if let index {
                                            selectedContracts.remove(at: index)
                                        } else {
                                            selectedContracts.append(contract.id)
                                        }
                                    }

                                } content: {
                                    hText(
                                        selectedContracts.firstIndex(of: contract.id) != nil
                                            ? L10n.ClaimStatus.ClaimHideDetails.button
                                            : L10n.ClaimStatus.ClaimDetails.button
                                    )
                                    .transition(.scale)
                                }
                            }
                        }
                    }
                }
            )
            .hCardWithoutSpacing
        }
        .sectionContainerStyle(.transparent)
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
        VStack(spacing: .padding16 * multiplier) {
            hRowDivider()
                .hWithoutDividerPadding

            if !contract.displayItems.isEmpty {
                VStack(alignment: .leading, spacing: multiplier != 1 ? .padding16 * multiplier : 0) {
                    hText(L10n.summaryScreenOverview)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(contract.displayItems, id: \.displayTitle) { item in
                        rowItem(for: item)
                    }
                }
            }

            if !contract.insuranceLimits.isEmpty {
                VStack(alignment: .leading, spacing: multiplier != 1 ? .padding16 * multiplier : 0) {
                    hText(L10n.summaryScreenCoverage)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(contract.insuranceLimits, id: \.limit) { limit in
                        let displayItem: QuoteDisplayItem = .init(title: limit.label, value: limit.limit, id: limit.id)
                        rowItem(for: displayItem)
                    }
                }
            }

            if !contract.documents.isEmpty {
                VStack(alignment: .leading, spacing: .padding4 * multiplier) {
                    hText(L10n.confirmationScreenDocumentTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(contract.documents, id: \.displayName) { document in
                        documentItem(for: document)
                            .background(hSurfaceColor.Opaque.primary)
                            .onTapGesture {
                                contract.onDocumentTap(document)
                            }
                    }
                }
            }
        }
        .padding(.bottom, (isExpanded && !vm.isAddon) ? .padding16 * multiplier : 0)
    }

    func rowItem(for displayItem: QuoteDisplayItem) -> some View {
        HStack(alignment: .top) {
            hText(displayItem.displayTitle)
            Spacer()

            if let oldValue = displayItem.displayValueOld, oldValue != displayItem.displayValue {
                if #available(iOS 16.0, *) {
                    hText(oldValue)
                        .strikethrough()
                } else {
                    hText(oldValue)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                }
            }

            hText(displayItem.displayValue)
                .multilineTextAlignment(.trailing)
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
            Image(uiImage: HCoreUIAsset.arrowNorthEast.image)
                .resizable()
                .frame(width: 24, height: 24)
        }
        .foregroundColor(hTextColor.Translucent.secondary)
    }

    private let whatIsCoveredBgColorScheme: some hColor = hColorScheme.init(
        light: hBlueColor.blue100,
        dark: hBlueColor.blue900
    )

    private func buttonComponent(proxy: ScrollViewProxy) -> some View {
        hSection {
            VStack(spacing: .padding16) {
                HStack {
                    hText(L10n.tierFlowTotal)
                    Spacer()

                    let amount = vm.total

                    if vm.isAddon {
                        VStack(alignment: .trailing, spacing: 0) {
                            if amount.value >= 0 {
                                hText(L10n.addonFlowPriceLabel(amount.formattedAmountWithoutSymbol))
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
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.onConfirmClick()
                    } content: {
                        hText(vm.isAddon ? L10n.addonFlowSummaryConfirmButton : L10n.changeAddressAcceptOffer)
                    }
                }
            }
        }
        .padding(.top, .padding16)
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    var chatComponent: some View {
        VStack(spacing: 0) {
            hText(L10n.changeAddressNoFind, style: .body1)
            Spacing(height: 16)
            hButton.SmallButton(type: .primary) {
                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
            } content: {
                hText(L10n.openChat, style: .body1)
            }
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
                onDocumentTap: { document in },
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
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { document in },
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
                typeOfContract: .seAccident
            ),
            .init(
                id: "id3",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                newPremium: .init(amount: 999, currency: "SEK"),
                currentPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { document in },
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
                onDocumentTap: { document in },
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
                onDocumentTap: { document in },
                displayItems: [],
                insuranceLimits: [],
                typeOfContract: .seDogStandard
            ),
        ],
        total: .init(amount: 999, currency: "SEK"),
        onConfirmClick: {}
    )

    return QuoteSummaryScreen(vm: vm)
})
