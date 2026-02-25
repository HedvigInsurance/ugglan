import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(_ removeAddonNavigationVm: RemoveAddonNavigationViewModel) {
        self.quoteSummaryVm = removeAddonNavigationVm.removeAddonVm
            .asQuoteSummaryViewModel(navigationVm: removeAddonNavigationVm)
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension RemoveAddonViewModel {
    func asQuoteSummaryViewModel(navigationVm: RemoveAddonNavigationViewModel) -> QuoteSummaryViewModel {
        let documents = removeOffer.productVariant.documents

        let typeOfContract: TypeOfContract? = TypeOfContract(rawValue: removeOffer.productVariant.typeOfContract)

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: removeOffer.contractInfo.contractId,
            title: removeOffer.contractInfo.exposureName,
            subtitle: removeOffer.contractInfo.displayName,
            premium: getPremium(),
            documentSection: .init(
                documents: documents,
                onTap: { [weak navigationVm] document in
                    navigationVm?.document = document
                }
            ),
            displayItems: [],
            insuranceLimits: [],
            typeOfContract: typeOfContract,
            priceBreakdownItems: getBreakdownDisplayItems()
        )

        let vm = QuoteSummaryViewModel(
            contract: [contractInfo],
            activationDate: removeOffer.activationDate,
            totalPrice: .none
        ) { [weak self, weak navigationVm] in
            navigationVm?.isProcessingPresented = true
            Task { await self?.confirmRemoval() }
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    let offer = AddonRemoveOfferWithSelectedItems(offer: testRemoveOffer, preselectedAddons: .init(), cost: nil)
    let navigationViewModel = RemoveAddonNavigationViewModel(offer)
    return RemoveAddonSummaryScreen(navigationViewModel)
}
