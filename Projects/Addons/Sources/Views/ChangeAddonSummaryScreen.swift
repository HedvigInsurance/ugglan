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
            changeAddonNavigationVm.changeAddonVm.selectedSubOption?.price

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.contractInformation?.contractId ?? "",
                    displayName: changeAddonNavigationVm.changeAddonVm.contractInformation?.contractName ?? "",
                    exposureName: changeAddonNavigationVm.changeAddonVm.contractInformation?.activationDate
                        .localDateString ?? "",
                    newPremium: newPremium,
                    currentPremium: nil,
                    documents: self.contractInformation?.documents ?? [],
                    onDocumentTap: { document in

                    },
                    displayItems: self.contractInformation?.displayItems ?? [],
                    insuranceLimits: self.contractInformation?.insurableLimits ?? [],
                    typeOfContract: nil
                )
            ],
            total: .init(
                amount: changeAddonNavigationVm.changeAddonVm.selectedSubOption?.price.formattedAmount ?? "",
                currency: "SEK"
            ),
            isAddon: true
        ) {
            changeAddonNavigationVm.changeAddonVm.submitAddons()
            changeAddonNavigationVm.router.push(ChangeAddonRouterActionsWithoutBackButton.commitAddon)
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(contractId: "")))
}
