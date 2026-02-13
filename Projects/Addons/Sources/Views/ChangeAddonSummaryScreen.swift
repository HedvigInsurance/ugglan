import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(_ changeAddonNavigationVm: ChangeAddonNavigationViewModel) {
        self.quoteSummaryVm = changeAddonNavigationVm.changeAddonVm!
            .asQuoteSummaryViewModel(changeAddonNavigationVm: changeAddonNavigationVm)
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeAddonViewModel {
    func asQuoteSummaryViewModel(changeAddonNavigationVm: ChangeAddonNavigationViewModel) -> QuoteSummaryViewModel {
        let documents = selectedAddons.flatMap { $0.addonVariant.documents }

        let typeOfContract: TypeOfContract? =
            if let addonOffer {
                TypeOfContract(rawValue: addonOffer.quote.productVariant.typeOfContract)
            } else { nil }

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: config.contractId,
            displayName: config.displayName,
            exposureName: config.exposureName,
            premium: getPremium(),
            documentSection: .init(
                documents: documents,
                onTap: { [weak changeAddonNavigationVm] document in
                    changeAddonNavigationVm?.document = document
                }
            ),
            displayItems: selectedAddons.flatMap(\.displayItems).map { $0.asQuoteDisplayItem() },
            insuranceLimits: [],
            typeOfContract: typeOfContract,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        let increase = getAddonPriceChange() ?? .zeroSek
        let vm = QuoteSummaryViewModel(
            contract: [contractInfo],
            activationDate: addonOffer?.quote.activationDate,
            noticeInfo: addonOffer?.infoMessage,
            totalPrice: .change(amount: increase.net)
        ) { [weak self, weak changeAddonNavigationVm] in
            changeAddonNavigationVm?.isAddonProcessingPresented = true
            Task { await self?.submitAddons() }
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })

    let navVm = ChangeAddonNavigationViewModel(
        input: .init(
            addonSource: .insurances,
            contractConfigs: [.init(contractId: "Id", exposureName: "title", displayName: "subtitle")]
        )
    )
    navVm.changeAddonVm?.addonOffer = testTravelOfferNoActive
    navVm.changeAddonVm?.selectedAddons = [travelQuote45Days]
    navVm.changeAddonVm?.addonOfferCost = testAddonOfferCost
    return ChangeAddonSummaryScreen(navVm)
}
