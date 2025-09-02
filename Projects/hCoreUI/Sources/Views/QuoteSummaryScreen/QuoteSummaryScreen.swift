import SwiftUI
import hCore

public struct QuoteSummaryScreen: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    @EnvironmentObject var router: Router
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
                    ContractCardView(vm: vm, proxy: proxy)
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
        .detent(
            presented: $vm.isConfirmChangesPresented,
            options: .constant([.alwaysOpenOnTop])
        ) {
            openConfirmChangesScreen
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
    let proxy: ScrollViewProxy

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
        let index = vm.expandedContracts.firstIndex(of: contract.id)
        let isExpanded = index != nil

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
                mainContent:
                    ContractInformation(
                        displayName: contract.displayName,
                        exposureName: vm.removedContracts.contains(contract.id) ? nil : contract.exposureName,
                        pillowImage: contract.typeOfContract?.pillowType.bgImage,
                        status: vm.removedContracts.contains(contract.id) ? L10n.contractStatusTerminated : nil
                    ),
                title: nil,
                subTitle: nil,
                bottomComponent: {
                    bottomComponent(for: contract, isExpanded: isExpanded)
                        .padding(.top, .padding16)
                }
            )
            .hCardWithoutSpacing
            .hCardBackgroundColor(vm.isAddon ? .light : .default)
        }
        .padding(.top, .padding8)
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func bottomComponent(
        for contract: QuoteSummaryViewModel.ContractInfo,
        isExpanded: Bool
    ) -> some View {
        VStack(spacing: .padding16) {
            if contract.shouldShowDetails {
                if !vm.removedContracts.contains(contract.id) {
                    showDetailsButton(contract)
                } else {
                    addButton(for: contract, isExpanded: isExpanded)
                }
            }

            if isExpanded {
                VStack(spacing: 0) {
                    detailsView(for: contract, isExpanded: isExpanded)
                        .frame(height: isExpanded ? nil : 0, alignment: .top)
                        .clipped()
                        .accessibilityHidden(!isExpanded)
                }
            }

            if !contract.discountDisplayItems.isEmpty && !vm.removedContracts.contains(contract.id) {
                VStack(spacing: .padding8) {
                    ForEach(contract.discountDisplayItems, id: \.displayTitle) { disocuntItem in
                        rowItem(for: disocuntItem, fontSize: .label)
                    }
                }
            }

            if (contract.shouldShowDetails && isExpanded) || !contract.discountDisplayItems.isEmpty {
                hRowDivider()
                    .hWithoutHorizontalPadding([.divider])
            }

            PriceField(
                newPremium: contract.netPremium,
                currentPremium: vm.removedContracts.contains(contract.id) ? nil : contract.grossPremium
            )
            .hWithStrikeThroughPrice(setTo: vm.removedContracts.contains(contract.id) ? .crossNewPrice : .crossOldPrice)
        }
    }

    @ViewBuilder
    private func showDetailsButton(_ contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        if vm.isAddon {
            hButton(
                .medium,
                .ghost,
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
            .hButtonWithBorder
        } else {
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

    func detailsView(for contract: QuoteSummaryViewModel.ContractInfo, isExpanded: Bool) -> some View {
        VStack(spacing: .padding16) {
            displayItemsView(for: contract)
            insuranceLimitsView(for: contract)
            documentsView(for: contract)
            removeButton(for: contract, isExpanded: isExpanded)
        }
        .padding(.bottom, (isExpanded && !contract.discountDisplayItems.isEmpty) ? .padding16 : 0)
    }

    @ViewBuilder
    func displayItemsView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
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
    }

    @ViewBuilder
    func insuranceLimitsView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
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
    }

    @ViewBuilder
    func documentsView(for contract: QuoteSummaryViewModel.ContractInfo) -> some View {
        if !contract.documents.isEmpty {
            VStack(alignment: .leading, spacing: .padding4) {
                hText(L10n.confirmationScreenDocumentTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                ForEach(contract.documents, id: \.displayName) { document in
                    documentItem(for: document)
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
    }

    private func addButton(for contract: QuoteSummaryViewModel.ContractInfo, isExpanded: Bool) -> some View {
        hButton(
            .medium,
            .secondary,
            content: .init(title: L10n.addonAddCoverage)
        ) { [weak vm] in
            withAnimation(.easeInOut(duration: 0.4)) {
                vm?.addContract(contract)
            }
        }
        .hWithTransition(.scale)
    }

    @ViewBuilder
    private func removeButton(for contract: QuoteSummaryViewModel.ContractInfo, isExpanded: Bool) -> some View {
        if let removeModel = contract.removeModel, !vm.removedContracts.contains(contract.id) && isExpanded {
            hButton(
                .medium,
                .secondary,
                content: .init(title: L10n.General.remove)
            ) { [weak vm] in
                withAnimation(.easeInOut(duration: 0.4)) {
                    vm?.removeModel = removeModel
                }
            }
            .hWithTransition(.scale)
        }
    }

    func rowItem(for displayItem: QuoteDisplayItem, fontSize: HFontTextStyle? = .body1) -> some View {
        HStack(alignment: .top) {
            hText(displayItem.displayTitle, style: fontSize ?? .body1)
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

            hText(displayItem.displayValue, style: fontSize ?? .body1)
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
}

private struct PriceSummarySection: View {
    @ObservedObject var vm: QuoteSummaryViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                let newPremium = vm.netTotal
                let currentPremium = vm.grossTotal
                if vm.isAddon {
                    HStack {
                        hText(L10n.tierFlowTotal)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            if newPremium.value >= 0 {
                                hText(newPremium.formattedAmountPerMonth)
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
                        newPremium: newPremium,
                        currentPremium: currentPremium,
                        title: nil,
                        subTitle: L10n.summaryTotalPriceSubtitle(vm.activationDate?.displayDateDDMMMYYYYFormat ?? "")
                    )
                    .hWithStrikeThroughPrice(setTo: .crossOldPrice)
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
                        router.dismiss()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
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
                netPremium: .init(amount: 999, currency: "SEK"),
                grossPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { document in },
                displayItems: [
                    .init(title: "Limits", value: "mockLimits mockLimits long long long name"),
                    .init(title: "Documents", value: "documents"),
                    .init(title: "FAQ", value: "mockFAQ"),
                ],
                insuranceLimits: [],
                typeOfContract: .seApartmentBrf,
                discountDisplayItems: [.init(title: "15% bundle discount", value: "-30 kr/mo")]
            ),
            .init(
                id: "id2",
                displayName: "Travel addon",
                exposureName: "Bellmansgtan 19A",
                netPremium: .init(amount: 999, currency: "SEK"),
                grossPremium: nil,
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
                typeOfContract: nil,
                isAddon: true,
                removeModel: .init(
                    id: "id2",
                    title: "Remove Travel Insurance Plus",
                    description:
                        "By removing this extended coverage, your insurance will no longer include extra protection while traveling.",
                    confirmButtonTitle: "Remove Travel Insurance Plus",
                    cancelRemovalButtonTitle: "Keep current coverage"
                ),
                discountDisplayItems: []
            ),
            .init(
                id: "id3",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                netPremium: .init(amount: 999, currency: "SEK"),
                grossPremium: .init(amount: 599, currency: "SEK"),
                documents: documents,
                onDocumentTap: { document in },
                displayItems: [],
                insuranceLimits: [
                    .init(label: "label", limit: "limit", description: "description"),
                    .init(label: "label2", limit: "limit2", description: "description2"),
                    .init(label: "label3", limit: "limit3", description: "description3"),
                ],
                typeOfContract: .seAccident,
                discountDisplayItems: []
            ),
            .init(
                id: "id4",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                netPremium: .init(amount: 999, currency: "SEK"),
                grossPremium: .init(amount: 599, currency: "SEK"),
                documents: [],
                onDocumentTap: { document in },
                displayItems: [],
                insuranceLimits: [],
                typeOfContract: .seAccident,
                discountDisplayItems: [
                    .init(title: "15% bundle discount", value: "-30 kr/mo"),
                    .init(title: "50% discount for 3 months", value: "-99 kr/mo"),
                ]
            ),
            .init(
                id: "id5",
                displayName: "Dog",
                exposureName: "Bellmansgtan 19A",
                netPremium: .init(amount: 999, currency: "SEK"),
                grossPremium: .init(amount: 599, currency: "SEK"),
                documents: [],
                onDocumentTap: { document in },
                displayItems: [],
                insuranceLimits: [],
                typeOfContract: .seDogStandard,
                discountDisplayItems: []
            ),
        ],
        activationDate: "2025-08-24".localDateToDate ?? Date(),
        summaryDataProvider: DirectQuoteSummaryDataProvider(
            intentCost: .init(totalGross: .sek(999), totalNet: .sek(599))
        ),
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
