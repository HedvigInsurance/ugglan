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

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.contractId ?? "",
                    displayName: self.selectedQuote?.productVariant.displayName ?? "",
                    exposureName: L10n.addonFlowSummaryActiveFrom(
                        self.addonOffer?.activationDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    newPremium: self.selectedQuote?.price,
                    currentPremium: nil,
                    documents: self.selectedQuote?.productVariant.documents ?? [],
                    onDocumentTap: { document in
                        changeAddonNavigationVm.document = document
                    },
                    displayItems: [],
                    insuranceLimits: self.selectedQuote?.productVariant.insurableLimits ?? [],
                    typeOfContract: nil
                )
            ],
            total: self.selectedQuote?.price ?? .init(amount: 0, currency: "SEK"),
            isAddon: true
        ) {
            Task {
                await self.submitAddons()
            }
            changeAddonNavigationVm.isConfirmAddonPresented = true
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(contractId: "")))
}
