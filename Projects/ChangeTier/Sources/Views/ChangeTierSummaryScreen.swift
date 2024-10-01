import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
        quoteSummaryVm = vm.asQuoteSummaryViewModel()
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeTierViewModel {
    func asQuoteSummaryViewModel() -> QuoteSummaryViewModel {
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
                    documents: self.selectedTier?.productVariant.documents ?? [],
                    onDocumentTap: { document in
                        if let url = URL(string: document.url) {
                            self.changeTierNavigationVm.document = .init(url: url, title: document.displayName)
                        }
                    },
                    displayItems: displayItems,
                    insuranceLimits: self.selectedTier?.productVariant.insurableLimits ?? [],
                    onLimitTap: { limit in
                        self.changeTierNavigationVm.isInsurableLimitPresented = limit
                    }
                )
            ],
            total: self.newPremium ?? .init(amount: "", currency: ""),
            FAQModel: (
                title: L10n.tierFlowQaTitle, subtitle: L10n.tierFlowQaSubtitle,
                questions: self.selectedTier?.FAQs ?? []
            ),
            onConfirmClick: {
                /* TODO: IMPLEMENT */
            }
        )
        return vm
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierSummaryScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
