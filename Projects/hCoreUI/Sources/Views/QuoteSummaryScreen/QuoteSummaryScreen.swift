import SwiftUI
import hCore

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
                    if vm.showNoticeCard {
                        noticeComponent
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
            ContractOverviewScreen(contract: contract, vm: vm)
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

    private let whatIsCoveredBgColorScheme: some hColor = hColorScheme.init(
        light: hBlueColor.blue100,
        dark: hBlueColor.blue900
    )

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
                    bottomComponent(for: contract)
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
    private func bottomComponent(
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
            if let netPremium = contract.premium?.net {
                PriceField(
                    viewModel: .init(
                        initialValue: contract.premium?.gross,
                        newValue: netPremium
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
                withAnimation(.easeInOut(duration: 0.4)) {
                    vm.isShowDetailsPresented = contract
                }
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
                let currentPremium = vm.premium.gross
                if let newPremium = vm.premium.net {
                    if vm.isAddon {
                        HStack {
                            hText(L10n.tierFlowTotal)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0) {
                                if newPremium.value >= 0 {
                                    hText(L10n.addonFlowPriceLabel(newPremium.formattedAmount))
                                } else {
                                    hText(newPremium.formattedAmountPerMonth)
                                }
                                hText(L10n.addonFlowSummaryPriceSubtitle, style: .label)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    } else {
                        PriceField(
                            viewModel: .init(
                                initialValue: currentPremium,
                                newValue: newPremium,
                                title: nil,
                                subTitle: L10n.summaryTotalPriceSubtitle(
                                    vm.activationDate?.displayDateDDMMMYYYYFormat ?? ""
                                )
                            )
                        )
                        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                    }
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
        .withDismissAlert(isPresented: $isCancelAlertPresented)
    }
}

#Preview(body: {
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
                    gross: nil,
                    net: .init(amount: 999, currency: "SEK")
                ),
                documentSection: .init(
                    documents: [],
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
                isAddon: true,
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
        premium: .init(gross: .sek(999), net: .sek(599)),
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
