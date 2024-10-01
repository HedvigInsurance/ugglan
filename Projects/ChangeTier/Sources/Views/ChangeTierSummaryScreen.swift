import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    var body: some View {
        let displayItems: [QuoteDisplayItem] =
            vm.selectedTier?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: vm.currentTier?.id ?? "",
                    displayName: vm.displayName ?? "",
                    exposureName: vm.exposureName ?? "",
                    newPremium: vm.newPremium,
                    currentPremium: vm.currentPremium,
                    documents: vm.selectedTier?.productVariant.documents ?? [],
                    onDocumentTap: { document in
                        if let url = URL(string: document.url) {
                            changeTierNavigationVm.document = .init(url: url, title: document.displayName)
                        }
                    },
                    displayItems: displayItems,
                    insuranceLimits: vm.selectedTier?.productVariant.insurableLimits ?? [],
                    onLimitTap: { limit in
                        changeTierNavigationVm.isInsurableLimitPresented = limit
                    }
                )
            ],
            total: vm.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: L10n.tierFlowQaTitle, subtitle: L10n.tierFlowQaSubtitle,
                questions: vm.selectedTier?.FAQs ?? []
            ),
            onConfirmClick: {
                /* TODO: IMPLEMENT */
            }
        )

        QuoteSummaryScreen(vm: vm)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierSummaryScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
