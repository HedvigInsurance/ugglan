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
        let selectedVariant = selectableAddons.first.flatMap { selectedQuote(for: $0)?.addonVariant }
        let documents = selectableAddons.flatMap { selectedQuote(for: $0)?.addonVariant.documents ?? [] }

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: contractId,
            displayName: selectedVariant?.displayName ?? "",
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

        let totalPrice = getTotalPrice()
        let vm = QuoteSummaryViewModel(
            contract: [
                contractInfo
            ],
            activationDate: activationDate,
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
