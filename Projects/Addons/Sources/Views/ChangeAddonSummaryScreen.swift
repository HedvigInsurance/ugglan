import SwiftUI
import hCore
import hCoreUI

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
                    id: self.contractInformation?.contractId ?? "",
                    displayName: "Reseskydd plus",
                    exposureName: "Tilläggsförsäkring",
                    newPremium: .init(amount: "49", currency: "SEK"),
                    currentPremium: .init(amount: "149", currency: "SEK"),
                    documents: self.contractInformation?.documents ?? [],
                    onDocumentTap: { document in

                    },
                    displayItems: self.contractInformation?.displayItems ?? [],
                    insuranceLimits: self.contractInformation?.insurableLimits ?? [],
                    typeOfContract: self.contractInformation?.typeOfContract
                )
            ],
            total: .init(amount: "220", currency: "SEK")
        ) {

        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(contractId: "")))
}
