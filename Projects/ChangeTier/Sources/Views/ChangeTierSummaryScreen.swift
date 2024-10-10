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
            self.selectedTier?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.currentTier?.id ?? "",
                    displayName: self.displayName ?? "",
                    exposureName: self.exposureName ?? "",
                    newPremium: self.newPremium,
                    currentPremium: self.currentPremium,
                    documents: self.selectedTier?.productVariant?.documents ?? [],
                    onDocumentTap: { [weak self] document in
                        if let url = URL(string: document.url) {
                            changeTierNavigationVm.document = .init(url: url, title: document.displayName)
                        }
                    },
                    displayItems: displayItems,
                    insuranceLimits: self.selectedTier?.productVariant?.insurableLimits ?? []
                )
            ],
            total: self.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: L10n.tierFlowQaTitle,
                subtitle: L10n.tierFlowQaSubtitle,
                questions: self.selectedTier?.FAQs ?? []
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
    let changeTierInput: ChangeTierInput = .init(source: .changeTier, contractId: "contractId")

    return ChangeTierSummaryScreen(
        changeTierVm: .init(changeTierInput: changeTierInput),
        changeTierNavigationVm: .init(vm: .init(changeTierInput: changeTierInput))
    )
}
