import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var changeTierVm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    var body: some View {
        let displayItems: [QuoteDisplayItem] =
            changeTierVm.selectedTier?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: changeTierVm.currentTier?.id ?? "",
                    displayName: changeTierVm.displayName ?? "",
                    exposureName: changeTierVm.exposureName ?? "",
                    newPremium: changeTierVm.newPremium,
                    currentPremium: changeTierVm.currentPremium,
                    documents: changeTierVm.selectedTier?.productVariant?.documents ?? [],
                    onDocumentTap: { document in
                        if let url = URL(string: document.url) {
                            changeTierNavigationVm.document = .init(url: url, title: document.displayName)
                        }
                    },
                    displayItems: displayItems,
                    insuranceLimits: changeTierVm.selectedTier?.productVariant?.insurableLimits ?? [],
                    onLimitTap: { limit in
                        changeTierNavigationVm.isInsurableLimitPresented = limit
                    }
                )
            ],
            total: changeTierVm.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: L10n.tierFlowQaTitle, subtitle: L10n.tierFlowQaSubtitle,
                questions: changeTierVm.selectedTier?.FAQs ?? []
            ),
            onConfirmClick: {
                changeTierVm.commitTier()
            }
        )

        QuoteSummaryScreen(vm: vm)
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierSummaryScreen(changeTierVm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
