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
            netPremium: selectedQuote?.price,
            grossPremium: addonOffer?.currentAddon?.price,
            documents: selectedQuote?.addonVariant?.documents ?? [],
            onDocumentTap: { document in
                changeAddonNavigationVm.document = document
            },
            displayItems: compareAddonDisplayItems(
                currentDisplayItems: addonOffer?.currentAddon?.displayItems ?? [],
                newDisplayItems: selectedQuote?.displayItems ?? []
            ),
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            discountDisplayItems: []
        )

        let vm = QuoteSummaryViewModel(
            contract: [
                contractInfo
            ],
            activationDate: self.addonOffer?.activationDate,
            isAddon: true,
            summaryDataProvider: DirectQuoteSummaryDataProvider(
                intentCost: .init(
                    totalGross: self.addonOffer?.currentAddon?.price ?? contractInfo.grossPremium
                        ?? .init(amount: "", currency: ""),
                    totalNet: getTotalPrice(
                        currentPrice: addonOffer?.currentAddon?.price,
                        newPrice: selectedQuote?.price
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
