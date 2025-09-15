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
            //            premium: .init(
            //                gross: addonOffer?.currentAddon?.price,
            //                net: selectedQuote?.
            //            ),
            premium: .init(
                gross: .sek(0),
                net: .sek(0)
            ),
            documentSection: .init(
                documents: selectedQuote?.documents ?? [],
                onTap: { [weak changeAddonNavigationVm] document in
                    changeAddonNavigationVm?.document = document
                }
            ),
            displayItems: compareAddonDisplayItems(
                currentDisplayItems: addonOffer?.currentAddon?.displayItems ?? [],
                newDisplayItems: selectedQuote?.displayItems ?? []
            ),
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            priceBreakdownItems: []
        )

        let vm = QuoteSummaryViewModel(
            contract: [
                contractInfo
            ],
            activationDate: self.addonOffer?.activationDate,
            isAddon: true,
            summaryDataProvider: DirectQuoteSummaryDataProvider(
                intentCost: .init(
                    gross: self.addonOffer?.currentAddon?.price.gross,
                    net: getTotalPrice(
                        currentPrice: addonOffer?.currentAddon?.price.net,
                        newPrice: selectedQuote?.price.net
                    )
                )
            )
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
