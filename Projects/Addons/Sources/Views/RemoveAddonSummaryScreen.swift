import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonSummaryScreen: View {
    let removeAddonNavigationVm: RemoveAddonNavigationViewModel

    init(_ removeAddonNavigationVm: RemoveAddonNavigationViewModel) {
        self.removeAddonNavigationVm = removeAddonNavigationVm
    }

    var body: some View {
        QuoteSummaryScreen(
            quoteSummary: removeAddonNavigationVm.removeAddonVm.asQuoteSummary(),
            onDocumentTap: { [weak removeAddonNavigationVm] in removeAddonNavigationVm?.document = $0 }
        ) { [weak removeAddonNavigationVm] in
            removeAddonNavigationVm?.isProcessingPresented = true
            Task { await removeAddonNavigationVm?.removeAddonVm.confirmRemoval() }
        }
    }
}

extension RemoveAddonViewModel {
    func asQuoteSummary() -> QuoteSummary {
        let documents = removeOffer.productVariant.documents

        let typeOfContract: TypeOfContract? = TypeOfContract(rawValue: removeOffer.productVariant.typeOfContract)

        let contractInfo: QuoteSummary.ContractInfo = .init(
            id: removeOffer.contractInfo.contractId,
            title: removeOffer.contractInfo.displayName,
            subtitle: removeOffer.contractInfo.exposureName,
            premium: getPremium(),
            documents: documents,
            displayItems: [],
            insuranceLimits: [],
            typeOfContract: typeOfContract,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        return QuoteSummary(
            contracts: [contractInfo],
            activationDate: removeOffer.activationDate,
            totalPrice: .none
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    let offer = AddonRemoveOfferWithSelectedItems(offer: testRemoveOffer, preselectedAddons: .init(), cost: nil)
    let navigationViewModel = RemoveAddonNavigationViewModel(offer)
    return RemoveAddonSummaryScreen(navigationViewModel)
}
