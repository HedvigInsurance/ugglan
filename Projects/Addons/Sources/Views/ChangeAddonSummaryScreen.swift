import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        quoteSummaryVm = changeAddonNavigationVm.changeAddonVm.asQuoteSummaryViewModel(
            changeAddonNavigationVm: changeAddonNavigationVm
        )
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeAddonViewModel {
    func asQuoteSummaryViewModel(changeAddonNavigationVm: ChangeAddonNavigationViewModel) -> QuoteSummaryViewModel {

        let newPremium =
            changeAddonNavigationVm.changeAddonVm.selectedQuote?.price

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.contractId ?? "",
                    displayName: self.selectedQuote?.productVariant.displayName ?? "",
                    exposureName: self.activationDate?.localDateString ?? "",
                    newPremium: newPremium,
                    currentPremium: nil,
                    documents: self.selectedQuote?.productVariant.documents ?? [],
                    onDocumentTap: { document in

                    },
                    displayItems: [], /* TODO: ADD */
                    insuranceLimits: self.selectedQuote?.productVariant.insurableLimits ?? [],
                    typeOfContract: nil
                )
            ],
            total: .init(
                amount: self.selectedQuote?.price?.formattedAmount ?? "",
                currency: "SEK"
            ),
            isAddon: true
        ) {
            Task {
                await self.submitAddons()
            }
            changeAddonNavigationVm.router.push(ChangeAddonRouterActionsWithoutBackButton.commitAddon)
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(contractId: "")))
}
