import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonSummaryScreen: View {
    let changeAddonNavigationVm: ChangeAddonNavigationViewModel

    init(_ changeAddonNavigationVm: ChangeAddonNavigationViewModel) {
        self.changeAddonNavigationVm = changeAddonNavigationVm
    }

    var body: some View {
        QuoteSummaryScreen(
            quoteSummary: changeAddonNavigationVm.changeAddonVm!.asQuoteSummary(),
            onDocumentTap: { [weak changeAddonNavigationVm] in changeAddonNavigationVm?.document = $0 }
        ) { [weak changeAddonNavigationVm] in
            changeAddonNavigationVm?.isAddonProcessingPresented = true
            Task { await changeAddonNavigationVm?.changeAddonVm?.submitAddons() }
        }
    }
}

extension ChangeAddonViewModel {
    func asQuoteSummary() -> QuoteSummary {
        let documents = offer.quote.productVariant.documents

        let typeOfContract = TypeOfContract(rawValue: offer.quote.productVariant.typeOfContract)

        let contractInfo: QuoteSummary.ContractInfo = .init(
            id: offer.contractInfo.contractId,
            title: offer.contractInfo.displayName,
            subtitle: offer.contractInfo.exposureName,
            premium: getPremium(),
            documents: documents,
            displayItems: selectedAddons.flatMap(\.displayItems).map { $0.asQuoteDisplayItem() },
            insuranceLimits: [],
            typeOfContract: typeOfContract,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        let increase = getAddonPriceChange() ?? .zeroSek
        return QuoteSummary(
            contracts: [contractInfo],
            activationDate: offer.quote.activationDate,
            noticeInfo: offer.infoMessage,
            totalPrice: .change(amount: increase.net)
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })

    let navVm = ChangeAddonNavigationViewModel(offer: testTravelOfferNoActive)
    navVm.changeAddonVm?.addonOfferCost = testAddonOfferCost
    return ChangeAddonSummaryScreen(navVm)
}
