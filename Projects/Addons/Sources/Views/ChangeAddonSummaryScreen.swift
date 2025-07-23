import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        quoteSummaryVm = changeAddonNavigationVm.changeAddonVm!
            .asQuoteSummaryViewModel(
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
                    id: self.contractId,
                    displayName: self.selectedQuote?.addonVariant?.displayName ?? "",
                    exposureName: L10n.addonFlowSummaryActiveFrom(
                        self.addonOffer?.activationDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    netPremium: self.selectedQuote?.price,
                    grossPremium: self.addonOffer?.currentAddon?.price,
                    documents: self.selectedQuote?.addonVariant?.documents ?? [],
                    onDocumentTap: { document in
                        changeAddonNavigationVm.document = document
                    },
                    displayItems: self.compareAddonDisplayItems(
                        currentDisplayItems: self.addonOffer?.currentAddon?.displayItems ?? [],
                        newDisplayItems: self.selectedQuote?.displayItems ?? []
                    ),
                    insuranceLimits: [],
                    typeOfContract: nil,
                    isAddon: true,
                    discountDisplayItems: []
                )
            ],
            netTotal: getTotalPrice(
                currentPrice: self.addonOffer?.currentAddon?.price,
                newPrice: self.selectedQuote?.price
            ),
            grossTotal: self.addonOffer?.currentAddon?.price,
            activationDate: self.addonOffer?.activationDate,
            isAddon: true
        ) {
            changeAddonNavigationVm.isConfirmAddonPresented = true
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(addonSource: .insurances)))
}
