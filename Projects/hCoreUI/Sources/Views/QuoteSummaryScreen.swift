import SwiftUI
import hCore
import hGraphQL

public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    let contracts: [ContractInfo]
    let total: MonetaryAmount
    let FAQModel: (title: String, subtitle: String, questions: [FAQ])
    let onConfirmClick: () -> Void

    public struct ContractInfo: Identifiable {
        public let id: String
        let displayName: String
        let exposureName: String
        let newPremium: MonetaryAmount?
        let currentPremium: MonetaryAmount?
        let displayItems: [QuoteDisplayItem]
        let documents: [InsuranceTerm]
        let onDocumentTap: (_ document: InsuranceTerm) -> Void
        let insuranceLimits: [InsurableLimits]
        let onLimitTap: (_ limit: InsurableLimits) -> Void

        public init(
            id: String,
            displayName: String,
            exposureName: String,
            newPremium: MonetaryAmount?,
            currentPremium: MonetaryAmount?,
            documents: [InsuranceTerm],
            onDocumentTap: @escaping (_ document: InsuranceTerm) -> Void,
            displayItems: [QuoteDisplayItem],
            insuranceLimits: [InsurableLimits],
            onLimitTap: @escaping (_ limit: InsurableLimits) -> Void
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
            self.onLimitTap = onLimitTap
        }
    }

    public init(
        contract: [ContractInfo],
        total: MonetaryAmount,
        FAQModel: (title: String, subtitle: String, questions: [FAQ]),
        onConfirmClick: @escaping () -> Void
    ) {
        self.contracts = contract
        self.total = total
        self.FAQModel = FAQModel
        self.onConfirmClick = onConfirmClick
    }
}

public struct QuoteSummaryScreen: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    private let showCoverageId = "showCoverageId"
    @State var selectedContracts: [String] = [""]
    @State var spacingCoverage: CGFloat = 0
    @State var totalHeight: CGFloat = 0
    @State var selectedFAQ: [String] = [""]

    public init(
        vm: QuoteSummaryViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            hForm {
                VStack(spacing: .padding16) {
                    VStack(spacing: .padding8) {
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
                    .padding(.bottom, spacingCoverage)
                }
                scrollSection
            }
            .hFormAttachToBottom {
                buttonComponent(proxy: proxy)
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

    var scrollSection: some View {
        VStack(spacing: 0) {
            ForEach(vm.contracts, id: \.id) { contract in
                coverageView(for: contract)
            }
            .padding(.top, .padding16)
            .id(showCoverageId)
            faqsComponent(for: vm.FAQModel.questions)
            chatComponent
        }
    }

    func contractInfoView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        hSection {
            StatusCard(
                onSelected: {

                },
                mainContent: ContractInformation(
                    displayName: contract.displayName,
                    exposureName: contract.exposureName
                ),
                title: nil,
                subTitle: nil,
                bottomComponent: {
                    VStack(spacing: .padding16) {
                        PriceField(
                            newPremium: contract.newPremium,
                            currentPremium: contract.currentPremium
                        )

                        let index = selectedContracts.firstIndex(of: contract.id)
                        let isExpanded = index != nil

                        if isExpanded {
                            detailsView(for: contract)
                        }

                        hButton.MediumButton(
                            type: .secondary
                        ) {
                            withAnimation {
                                let index = selectedContracts.firstIndex(of: contract.id)
                                if let index {
                                    selectedContracts.remove(at: index)
                                } else {
                                    selectedContracts.append(contract.id)
                                }
                            }

                        } content: {
                            let index = selectedContracts.firstIndex(of: contract.id)
                            hText(index != nil ? "Hide details" : L10n.ClaimStatus.ClaimDetails.button)
                        }
                    }
                }
            )
            .hCardWithoutSpacing
        }
        .sectionContainerStyle(.transparent)
    }

    func detailsView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        VStack(spacing: .padding16) {
            hRowDivider()
                .hWithoutDividerPadding
            VStack(alignment: .leading, spacing: 0) {
                hText("Details")
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(contract.displayItems) { item in
                    rowItem(for: item)
                }
            }
        }
    }

    func rowItem(for displayItem: QuoteDisplayItem) -> some View {
        HStack {
            hText(displayItem.displayTitle)
            Spacer()
            hText(displayItem.displayValue)
        }
        .foregroundColor(hTextColor.Opaque.secondary)
    }

    func coverageView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        VStack(spacing: 0) {
            hSection {
                VStack {
                    hText(contract.exposureName, style: .body1)
                        .padding(.vertical, .padding4)
                        .padding(.horizontal, .padding8)

                }
                .background(whatIsCoveredBgColorScheme)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)

            Spacing(height: 16)

            InsurableLimitsSectionView(limits: contract.insuranceLimits) { limit in
                contract.onLimitTap(limit)
            }

            Spacing(height: 32)

            InsuranceTermView(documents: contract.documents) { document in
                contract.onDocumentTap(document)
            }

            Spacing(height: 40)
        }
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
                    hText(vm.total.formattedAmountPerMonth)
                }
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.onConfirmClick()
                    } content: {
                        hText("Confirm changes")
                    }
                    hButton.LargeButton(type: .ghost) {
                        withAnimation {
                            proxy.scrollTo(showCoverageId, anchor: .top)
                        }
                    } content: {
                        hText(L10n.tierFlowShowCoverage)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    func faqsComponent(for faqs: [FAQ]) -> some View {
        VStack {
            if !faqs.isEmpty {
                hSection {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(vm.FAQModel.title)
                        hText(vm.FAQModel.subtitle).foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    ForEach(faqs, id: \.title) { faq in
                        let id = "\(faq.title)"
                        let index = selectedFAQ.firstIndex(of: id)
                        let expanded = index != nil
                        hSection {
                            VStack(spacing: 0) {
                                hRow {
                                    hText(faq.title)
                                    Spacer()
                                }
                                .withCustomAccessory {
                                    Image(
                                        uiImage: expanded ? hCoreUIAssets.minus.image : hCoreUIAssets.plusSmall.image
                                    )
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                }
                                .verticalPadding(.padding12)
                                if expanded, let description = faq.description {
                                    hRow {
                                        hText(description, style: .label)
                                            .foregroundColor(hTextColor.Opaque.secondary)

                                    }
                                    .verticalPadding(.padding12)
                                }
                            }
                        }
                        .onTapGesture {
                            let index = selectedFAQ.firstIndex(of: id)
                            withAnimation {
                                if let index {
                                    selectedFAQ.remove(at: index)
                                } else {
                                    selectedFAQ.append(id)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
    }

    @ViewBuilder
    var chatComponent: some View {
        VStack(spacing: 0) {
            Spacing(height: 64)
            hText(L10n.changeAddressNoFind, style: .body1)
            Spacing(height: 16)
            hButton.SmallButton(type: .primary) {
                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
            } content: {
                hText(L10n.openChat, style: .body1)
            }
            .fixedSize()
            Spacing(height: 103)
        }
    }
}

/* TODO: MOVE */
struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?

    var body: some View {
        HStack(spacing: .padding12) {
            Image(uiImage: hCoreUIAssets.pillowHome.image)
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                hText(displayName ?? "", style: .heading1)
                hText(exposureName ?? "", style: .body1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PriceField: View {
    let newPremium: MonetaryAmount?
    let currentPremium: MonetaryAmount?

    var body: some View {

        HStack(alignment: .top) {
            hText(L10n.tierFlowTotal)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                if let newPremium = newPremium {
                    hText(newPremium.formattedAmountPerMonth)
                } else {
                    hText(currentPremium?.formattedAmountPerMonth ?? "")
                }

                if newPremium != currentPremium {
                    hText(
                        L10n.tierFlowPreviousPrice(currentPremium?.formattedAmountPerMonth ?? ""),
                        style: .label
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        }
    }
}

public struct QuoteDisplayItem: Identifiable {
    public let id: String?
    let displayTitle: String
    let displayValue: String

    public init(
        title displayTitle: String,
        value displayValue: String,
        id: String? = nil
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
        self.id = id
    }
}

public struct FAQ: Codable, Equatable, Hashable {
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
    let mockLimits: [InsurableLimits] = [
        .init(label: "Insured amount", limit: "1 000 000 kr", description: ""),
        .init(label: "Insured amount", limit: "1 000 000 kr", description: ""),
        .init(label: "Insured amount", limit: "1 000 000 kr", description: ""),
    ]

    let documents: [InsuranceTerm] = [
        .init(displayName: "document 1", url: "https//hedvig.com", type: .generalTerms),
        .init(displayName: "document 2", url: "https//hedvig.com", type: .preSaleInfo),
    ]

    let mockFAQ: [FAQ] = [
        .init(title: "question 1", description: "..."),
        .init(title: "question 2", description: "..."),
        .init(title: "question 3", description: "..."),
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
                    .init(title: "Limits", value: "mockLimits"),
                    .init(title: "Documents", value: "documents"),
                    .init(title: "FAQ", value: "mockFAQ"),
                ],
                insuranceLimits: mockLimits,
                onLimitTap: { limit in }
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
                insuranceLimits: mockLimits,
                onLimitTap: { limit in }
            ),
        ],
        total: .init(amount: 999, currency: "SEK"),
        FAQModel: (
            title: "Questions and answers", subtitle: "Här reder vi ut våra medlemmars vanligaste funderingar.",
            questions: mockFAQ
        ),
        onConfirmClick: {}
    )

    return QuoteSummaryScreen(vm: vm)
})
