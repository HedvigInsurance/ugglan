import SwiftUI
import hCore

struct ContractOverviewScreen: View {
    let contract: QuoteSummaryViewModel.ContractInfo
    @ObservedObject var vm: QuoteSummaryViewModel

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                overviewSection
                coverageSection
                documentSection
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding([.row, .divider])
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hCloseButton {
                vm.isShowDetailsPresented = nil
            }
        }
        .embededInNavigation(
            tracking: self
        )
    }

    @ViewBuilder
    private var overviewSection: some View {
        let displayItems = contract.displayItems
        if !displayItems.isEmpty {
            hSection(displayItems) { item in
                QuoteDisplayItemView(displayItem: item)
            }
            .withHeader(title: L10n.summaryScreenOverview)
            .accessibilityElement(children: .combine)
            .accessibilityRemoveTraits(.isHeader)
        }
    }

    @ViewBuilder
    private var coverageSection: some View {
        let coverageItems = contract.insuranceLimits
        if !coverageItems.isEmpty {
            hSection(coverageItems, id: \.id) { item in
                QuoteDisplayItemView(
                    displayItem: .init(
                        title: item.label,
                        value: item.limit ?? "",
                        id: item.id
                    )
                )
            }
            .withHeader(title: L10n.summaryScreenCoverage)
            .accessibilityElement(children: .combine)
            .accessibilityRemoveTraits(.isHeader)
        }
    }

    @ViewBuilder
    private var documentSection: some View {
        let documentItems = contract.documentSection.documents
        if !documentItems.isEmpty {
            hSection(documentItems) { document in
                DocumentRowItemView(
                    document: document,
                    onTap: { document in
                        contract.documentSection.onTap(document)
                    }
                )
            }
            .withHeader(title: L10n.confirmationScreenDocumentTitle)
        }
    }
}

extension ContractOverviewScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: ContractOverviewScreen.self)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    let vm = QuoteSummaryViewModel(
        contract: [],
        activationDate: "2025-08-24".localDateToDate ?? Date(),
        summaryDataProvider: DirectQuoteSummaryDataProvider(
            intentCost: .init(gross: .sek(999), net: .sek(599))
        ),
        onConfirmClick: {}
    )

    return ContractOverviewScreen(
        contract:
            .init(
                id: "id1",
                displayName: "Homeowner",
                exposureName: "Bellmansgtan 19A",
                premium: .init(
                    gross: .init(amount: 599, currency: "SEK"),
                    net: .init(amount: 999, currency: "SEK")
                ),
                documentSection: .init(
                    documents: [
                        .init(displayName: "Insurance terms", url: "url", type: .generalTerms),
                        .init(displayName: "Pre sale information", url: "url", type: .generalTerms),
                        .init(displayName: "Product facts", url: "url", type: .generalTerms),
                    ],
                    onTap: { document in }
                ),
                displayItems: [
                    .init(title: "Limits", value: "mockLimits mockLimits long long long name"),
                    .init(title: "Documents", value: "documents"),
                    .init(title: "FAQ", value: "mockFAQ"),
                ],
                insuranceLimits: [
                    .init(label: "Your belongings", description: "3 000 000 kr"),
                    .init(label: "All-risk", description: "100 000 kr"),
                ],
                typeOfContract: .seApartmentBrf,
                priceBreakdownItems: [.init(title: "15% bundle discount", value: "-30 kr/mo")]
            ),
        vm: vm,
    )
}
