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
        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: contractId,
            displayName: selectedQuote?.addonVariant?.displayName ?? "",
            exposureName: L10n.addonFlowSummaryActiveFrom(
                addonOffer?.activationDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            premium: getPremium(),
            documentSection: .init(
                documents: selectedQuote?.documents ?? [],
                onTap: { [weak changeAddonNavigationVm] document in
                    changeAddonNavigationVm?.document = document
                }
            ),
            displayItems: compareAddonDisplayItems(
                newDisplayItems: selectedQuote?.displayItems ?? []
            ),
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        let totalPrice = getTotalPrice()
        let vm = QuoteSummaryViewModel(
            contract: [
                contractInfo
            ],
            activationDate: self.addonOffer?.activationDate,
            premium: .init(
                gross: totalPrice,
                net: totalPrice
            ),
            isAddon: true
        ) { [weak self, weak changeAddonNavigationVm] in
            changeAddonNavigationVm?.isAddonProcessingPresented = true
            Task {
                guard let self else { return }
                await self.submitAddons()
            }
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(addonSource: .insurances)))
}
