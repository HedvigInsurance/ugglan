import SwiftUI
import hCore

public struct QuoteSummaryScreen: View {
    let quoteSummary: QuoteSummary
    let onDocumentTap: (hPDFDocument) -> Void
    let onConfirm: () -> Void

    @State private var isConfirmChangesPresented = false
    @State private var showDetailsContract: QuoteSummary.ContractInfo? = nil
    @State private var spacingCoverage: CGFloat = 0
    @State private var totalHeight: CGFloat = 0

    public init(
        quoteSummary: QuoteSummary,
        onDocumentTap: @escaping (hPDFDocument) -> Void,
        onConfirm: @escaping () -> Void
    ) {
        self.quoteSummary = quoteSummary
        self.onDocumentTap = onDocumentTap
        self.onConfirm = onConfirm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            hForm {
                VStack(spacing: .padding16) {
                    ContractCardView(
                        contracts: quoteSummary.contracts,
                        showDetailsContract: $showDetailsContract
                    )
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
                    if let noticeInfo = quoteSummary.noticeInfo {
                        noticeComponent(info: noticeInfo)
                    }
                    PriceSummarySection(
                        quoteSummary: quoteSummary,
                        isConfirmChangesPresented: $isConfirmChangesPresented
                    )
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
            presented: $isConfirmChangesPresented,
            options: .constant([.alwaysOpenOnTop])
        ) {
            openConfirmChangesScreen
        }
        .detent(
            item: $showDetailsContract,
            options: .constant([.alwaysOpenOnTop]),
        ) { contract in
            ContractOverviewScreen(contract: contract, onDocumentTap: onDocumentTap)
        }
    }

    private var openConfirmChangesScreen: some View {
        let confirmChangesView =
            ConfirmChangesScreen(
                title: L10n.confirmChangesTitle,
                subTitle: L10n.confirmChangesSubtitle(
                    quoteSummary.activationDate?.displayDateDDMMMYYYYFormat ?? Date().displayDateDDMMMYYYYFormat
                ),
                buttons: .init(
                    mainButton: .init(buttonAction: {
                        isConfirmChangesPresented = false
                        onConfirm()
                    }),
                    dismissButton: .init(buttonAction: {
                        isConfirmChangesPresented = false
                    })
                )
            )

        return
            confirmChangesView
            .embededInNavigation(
                tracking: confirmChangesView
            )
    }

    private func noticeComponent(info: String) -> some View {
        hSection {
            InfoCard(
                text: info,
                type: .info
            )
        }
        .sectionContainerStyle(.transparent)
    }
}

private struct ContractCardView: View {
    let contracts: [QuoteSummary.ContractInfo]
    @Binding var showDetailsContract: QuoteSummary.ContractInfo?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(contracts) { contract in
                contractInfoView(for: contract)
                    .id(contract.id)
            }
        }
    }

    @ViewBuilder
    private func contractInfoView(for contract: QuoteSummary.ContractInfo) -> some View {
        hSection {
            StatusCard(
                mainContent:
                    ContractInformation(
                        title: contract.title,
                        subtitle: contract.subtitle,
                        pillowImage: contract.typeOfContract?.pillowType.bgImage,
                        status: nil
                    ),
                title: nil,
                subTitle: nil,
                accessibilityWithoutCombinedElements: true,
                bottomComponent: {
                    pricingSummary(for: contract)
                        .padding(.top, .padding16)
                }
            )
            .hCardWithoutSpacing
            .hCardBackgroundColor(.light)
        }
        .padding(.top, .padding8)
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func pricingSummary(for contract: QuoteSummary.ContractInfo) -> some View {
        VStack(spacing: .padding16) {
            if contract.shouldShowDetails {
                showDetailsButton(contract)
            }

            if !contract.priceBreakdownItems.isEmpty {
                VStack(spacing: .padding4) {
                    ForEach(contract.priceBreakdownItems, id: \.displayTitle) { disocuntItem in
                        QuoteDisplayItemView(displayItem: disocuntItem)
                    }
                }
                .hWithoutHorizontalPadding([.row])
            }

            if (contract.shouldShowDetails || !contract.priceBreakdownItems.isEmpty) {
                hRowDivider()
                    .hWithoutHorizontalPadding([.divider])
            }
            if let premium = contract.premium {
                PriceField(
                    viewModel: .init(
                        initialValue: premium.gross,
                        newValue: premium.net
                    )
                )
                .hWithStrikeThroughPrice(
                    setTo: .crossOldPrice
                )
            }
        }
    }

    @ViewBuilder
    private func showDetailsButton(_ contract: QuoteSummary.ContractInfo) -> some View {
        hButton(
            .medium,
            .ghost,
            content: .init(
                title: L10n.ClaimStatus.ClaimDetails.button
            )
        ) {
            showDetailsContract = contract
        }
        .hWithTransition(.scale)
        .hButtonWithBorder
    }
}

private struct PriceSummarySection: View {
    let quoteSummary: QuoteSummary
    @Binding var isConfirmChangesPresented: Bool
    @State private var isCancelAlertPresented = false

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                switch quoteSummary.totalPrice {
                case .comparison(let currentPrice, let newPrice):
                    PriceField(
                        viewModel: .init(
                            initialValue: currentPrice,
                            newValue: newPrice,
                            title: nil,
                            subTitle: L10n.summaryTotalPriceSubtitle(
                                quoteSummary.activationDate?.displayDateDDMMMYYYYFormat ?? ""
                            )
                        )
                    )
                    .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                case .change(let amount):
                    HStack {
                        hText(L10n.tierFlowTotal)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            if amount.value >= 0 {
                                hText(L10n.addonFlowPriceLabel(amount.formattedAmount))
                            } else {
                                hText(amount.formattedAmountPerMonth)
                            }
                            hText(L10n.addonFlowSummaryPriceSubtitle, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                case .none: EmptyView()
                }
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(
                            title: L10n.changeAddressAcceptOffer
                        )
                    ) { isConfirmChangesPresented = true }

                    hCancelButton {
                        isCancelAlertPresented = true
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .withAlertDismiss()
        .configureAlert(isPresented: $isCancelAlertPresented)
    }
}

#Preview(
    body: {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })

        let documents: [hPDFDocument] = [
            .init(displayName: "document 1", url: "https//hedvig.com", type: .generalTerms),
            .init(displayName: "document 2", url: "https//hedvig.com", type: .preSaleInfo),
        ]
        let quoteSummary = QuoteSummary(
            contracts: [
                .init(
                    id: "id1",
                    title: "Homeowner",
                    subtitle: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documents: [],
                    displayItems: [
                        .init(title: "Limits", value: "mockLimits mockLimits long long long name"),
                        .init(title: "Documents", value: "documents"),
                        .init(title: "FAQ", value: "mockFAQ"),
                    ],
                    insuranceLimits: [],
                    typeOfContract: .seApartmentBrf,
                    priceBreakdownItems: [.init(title: "15% bundle discount", value: "-30 kr/mo")]
                ),
                .init(
                    id: "id2",
                    title: "Travel addon",
                    subtitle: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documents: documents,
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
                    priceBreakdownItems: []
                ),
                .init(
                    id: "id3",
                    title: "Homeowner",
                    subtitle: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documents: [],
                    displayItems: [],
                    insuranceLimits: [
                        .init(label: "label", limit: "limit", description: "description"),
                        .init(label: "label2", limit: "limit2", description: "description2"),
                        .init(label: "label3", limit: "limit3", description: "description3"),
                    ],
                    typeOfContract: .seAccident,
                    priceBreakdownItems: []
                ),
                .init(
                    id: "id4",
                    title: "Homeowner",
                    subtitle: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documents: [],
                    displayItems: [],
                    insuranceLimits: [],
                    typeOfContract: .seAccident,
                    priceBreakdownItems: [
                        .init(title: "15% bundle discount", value: "-30 kr/mo"),
                        .init(title: "50% discount for 3 months", value: "-99 kr/mo"),
                    ]
                ),
                .init(
                    id: "id5",
                    title: "Dog",
                    subtitle: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documents: [],
                    displayItems: [],
                    insuranceLimits: [],
                    typeOfContract: .seDogStandard,
                    priceBreakdownItems: []
                ),
            ],
            activationDate: "2025-08-24".localDateToDate ?? Date(),
            totalPrice: .comparison(old: .sek(599), new: .sek(999))
        )

        return QuoteSummaryScreen(quoteSummary: quoteSummary, onDocumentTap: { _ in }) {}
    }
)
