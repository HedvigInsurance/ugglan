import SwiftUI
import hCore

public struct QuoteSummaryScreen: View {
    @ObservedObject var vm: QuoteSummaryViewModel
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
                    ContractCardView(vm: vm)
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
                    if let noticeInfo = vm.noticeInfo {
                        noticeComponent(info: noticeInfo)
                    }
                    PriceSummarySection(vm: vm)
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
            presented: $vm.isConfirmChangesPresented,
            options: .constant([.alwaysOpenOnTop])
        ) {
            openConfirmChangesScreen
        }
        .detent(
            item: $vm.isShowDetailsPresented,
            options: .constant([.alwaysOpenOnTop]),
        ) { contract in
            ContractOverviewScreen(contract: contract)
        }
    }

    private var openConfirmChangesScreen: some View {
        let confirmChangesView =
            ConfirmChangesScreen(
                title: L10n.confirmChangesTitle,
                subTitle: L10n.confirmChangesSubtitle(
                    vm.activationDate?.displayDateDDMMMYYYYFormat ?? Date().displayDateDDMMMYYYYFormat
                ),
                buttons: .init(
                    mainButton: .init(buttonAction: { [weak vm] in
                        vm?.isConfirmChangesPresented = false
                        vm?.onConfirmClick()
                    }),
                    dismissButton: .init(buttonAction: { [weak vm] in
                        vm?.isConfirmChangesPresented = false
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
    @ObservedObject var vm: QuoteSummaryViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(vm.contracts, id: \.id) { contract in
                contractInfoView(for: contract)
                    .id(contract.id)
            }
        }
    }

    @ViewBuilder
    private func contractInfoView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        contractContent(for: contract)
    }

    func contractContent(
        for contract: QuoteSummaryViewModel.ContractInfo
    ) -> some View {
        hSection {
            StatusCard(
                onSelected: {},
                mainContent:
                    ContractInformation(
                        displayName: contract.displayName,
                        exposureName: contract.exposureName,
                        pillowImage: contract.typeOfContract?.pillowType.bgImage,
                        status: nil
                    ),
                title: nil,
                subTitle: nil,
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
    private func pricingSummary(
        for contract: QuoteSummaryViewModel.ContractInfo
    ) -> some View {
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
                .accessibilityElement(children: .combine)
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
    private func showDetailsButton(_ contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        hButton(
            .medium,
            .ghost,
            content: .init(
                title: L10n.ClaimStatus.ClaimDetails.button
            ),
            {
                vm.isShowDetailsPresented = contract
            }
        )
        .hWithTransition(.scale)
        .hButtonWithBorder
    }
}

private struct PriceSummarySection: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    @State private var isCancelAlertPresented = false

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                switch vm.totalPrice {
                case .comparison(let currentPrice, let newPrice):
                    PriceField(
                        viewModel: .init(
                            initialValue: currentPrice,
                            newValue: newPrice,
                            title: nil,
                            subTitle: L10n.summaryTotalPriceSubtitle(
                                vm.activationDate?.displayDateDDMMMYYYYFormat ?? ""
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
                        ),
                        { [weak vm] in
                            vm?.isConfirmChangesPresented = true
                        }
                    )

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
        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: "id1",
                    displayName: "Homeowner",
                    exposureName: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documentSection: .init(
                        documents: [],
                        onTap: { document in }
                    ),
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
                    displayName: "Travel addon",
                    exposureName: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documentSection: .init(
                        documents: documents,
                        onTap: { document in }
                    ),
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
                    displayName: "Homeowner",
                    exposureName: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documentSection: .init(
                        documents: [],
                        onTap: { document in }
                    ),
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
                    displayName: "Homeowner",
                    exposureName: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documentSection: .init(
                        documents: [],
                        onTap: { document in }
                    ),
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
                    displayName: "Dog",
                    exposureName: "Bellmansgtan 19A",
                    premium: .init(
                        gross: .init(amount: 599, currency: "SEK"),
                        net: .init(amount: 999, currency: "SEK")
                    ),
                    documentSection: .init(
                        documents: [],
                        onTap: { document in }
                    ),
                    displayItems: [],
                    insuranceLimits: [],
                    typeOfContract: .seDogStandard,
                    priceBreakdownItems: []
                ),
            ],
            activationDate: "2025-08-24".localDateToDate ?? Date(),
            totalPrice: .comparison(old: .sek(599), new: .sek(999)),
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
        self.environment(\.hAccessibilityWithoutCombinedElements, true)
    }
}
