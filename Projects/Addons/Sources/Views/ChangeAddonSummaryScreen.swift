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
        let documents = offer.quote.productVariant.documents

        let typeOfContract = TypeOfContract(rawValue: offer.quote.productVariant.typeOfContract)

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: offer.contractInfo.contractId,
            title: offer.contractInfo.displayName,
            subtitle: offer.contractInfo.exposureName,
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
            activationDate: offer.quote.activationDate,
            noticeInfo: offer.infoMessage,
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
        .init(
            offer: testTravelOfferNoActive,
            preselectedAddonTitle: nil,
            cost: testAddonOfferCost
        )
    )
    return ChangeAddonSummaryScreen(navVm)
}
