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
                    newPremium: self.selectedQuote?.price,
                    currentPremium: self.addonOffer?.currentAddon?.price,
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
            total: getTotalPrice(
                currentPrice: self.addonOffer?.currentAddon?.price,
                newPrice: self.selectedQuote?.price
            ),
            activationDate: self.addonOffer?.activationDate ?? Date(),
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
