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
        let documents = selectedAddons.flatMap { $0.addonVariant.documents }
        let displayName = selectedAddons.map { $0.addonVariant.displayName }.joined(separator: ", ")

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: contractId,
            displayName: displayName,
            exposureName: L10n.addonFlowSummaryActiveFrom(
                activationDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            premium: getPremium(),
            documentSection: .init(
                documents: documents,
                onTap: { [weak changeAddonNavigationVm] document in
                    changeAddonNavigationVm?.document = document
                }
            ),
            displayItems: getDisplayItems(),
            insuranceLimits: [],
            typeOfContract: nil,
            isAddon: true,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        let priceIncrease = getPriceIncrease(offer: addonOffer!, for: addonType!)

        let vm = QuoteSummaryViewModel(
            contract: [contractInfo],
            activationDate: activationDate,
            premium: .init(
                gross: priceIncrease.gross,
                net: priceIncrease.net
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
    return ChangeAddonSummaryScreen(
        changeAddonNavigationVm: .init(
            input: .init(
                addonSource: .insurances,
                contractConfigs: [
                    .init(contractId: "contractId", exposureName: "exposureName", displayName: "displayName")
                ]
            )
        )
    )
}
