import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeTierSummaryScreen: View {
    @ObservedObject var changeTierVm: ChangeTierViewModel
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeTierVm: ChangeTierViewModel,
        changeTierNavigationVm: ChangeTierNavigationViewModel
    ) {
        self.changeTierVm = changeTierVm
        quoteSummaryVm = changeTierVm.asQuoteSummaryViewModel(changeTierNavigationVm: changeTierNavigationVm)
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeTierViewModel {
    func asQuoteSummaryViewModel(changeTierNavigationVm: ChangeTierNavigationViewModel) -> QuoteSummaryViewModel {
        let displayItems: [QuoteDisplayItem] =
            self.selectedQuote?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.currentTier?.id ?? "",
                    displayName: self.displayName ?? "",
                    exposureName: self.exposureName ?? "",
                    newPremium: self.newPremium,
                    currentPremium: self.currentPremium,
                    documents: self.selectedQuote?.productVariant?.documents ?? [],
                    onDocumentTap: { [weak self] document in
                        changeTierNavigationVm.document = document
                    },
                    displayItems: displayItems,
                    insuranceLimits: self.selectedQuote?.productVariant?.insurableLimits ?? [],
                    typeOfContract: self.typeOfContract
                )
            ],
            total: self.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: L10n.tierFlowQaTitle,
                subtitle: L10n.tierFlowQaSubtitle,
                questions: []
            ),
            onConfirmClick: {
                self.commitTier()
                changeTierNavigationVm.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
            }
        )

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let changeTierInput: ChangeTierInput = .contractWithSource(
        data: .init(source: .betterCoverage, contractId: "contractId")
    )
    let changeTierVm = ChangeTierViewModel(changeTierInput: changeTierInput)
    return ChangeTierSummaryScreen(
        changeTierVm: changeTierVm,
        changeTierNavigationVm: .init(router: Router(), vm: changeTierVm)
    )
}
