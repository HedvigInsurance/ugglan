import SwiftUI
import hCore
import hCoreUI
/* todo: remove */
import hGraphQL

struct ChangeTierSummaryScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var selectTierNavigationVm: ChangeTierNavigationViewModel

    var body: some View {

        let displayItems: [QuoteDisplayItem] =
            vm.selectedTier?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []

        /* TODO: REMOVE */
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
                    id: vm.currentTier?.id ?? "", /* TODO: IMPLEMENT */
                    displayName: vm.displayName ?? "",
                    exposureName: vm.exposureName ?? "",
                    newPremium: vm.newPremium,
                    currentPremium: vm.currentPremium,
                    documents: documents,  //vm.selectedTier?.productVariant.documents ?? [],,
                    onDocumentTap: { document in
                        /* TODO: IMPLEMENT */
                    },
                    displayItems: displayItems,
                    insuranceLimits: mockLimits,  // vm.selectedTier?.productVariant.insurableLimits
                    onLimitTap: { limit in
                        selectTierNavigationVm.isInsurableLimitPresented = limit
                    }
                )
            ],
            total: vm.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: "Questions and answers", subtitle: "Här reder vi ut våra medlemmars vanligaste funderingar.",
                questions: mockFAQ
            ),
            onConfirmClick: {
                /* TODO: IMPLEMENT */
            }
        )

        QuoteSummaryScreen(vm: vm)
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierSummaryScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
