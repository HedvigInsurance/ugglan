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
        let documents = removeOffer?.productVariant.documents ?? []

        let typeOfContract: TypeOfContract? =
            if let removeOffer {
                TypeOfContract(rawValue: removeOffer.productVariant.typeOfContract)
            } else { nil }

        let contractInfo: QuoteSummaryViewModel.ContractInfo = .init(
            id: contractInfo.contractId,
            displayName: contractInfo.displayName,
            exposureName: contractInfo.exposureName,
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
            activationDate: removeOffer?.activationDate,
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
    return RemoveAddonSummaryScreen(.init(.init(contractId: "1", exposureName: "exposure", displayName: "title"), []))
}
