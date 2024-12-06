import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        quoteSummaryVm = changeAddonNavigationVm.changeAddonVm.asQuoteSummaryViewModel(
            changeAddonNavigationVm: changeAddonNavigationVm
        )
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeAddonViewModel {
    func asQuoteSummaryViewModel(changeAddonNavigationVm: ChangeAddonNavigationViewModel) -> QuoteSummaryViewModel {

        let currentPrice = self.addonOffer?.currentAddon?.price
        let newPrice = self.selectedQuote?.price
        let diffValue: Float = {
            if let currentPrice, let newPrice {
                return newPrice.value - currentPrice.value
            } else {
                return 0
            }
        }()

        let totalPrice =
            (currentPrice != nil && diffValue != 0) ? .init(amount: String(diffValue), currency: "SEK") : newPrice

        let vm = QuoteSummaryViewModel(
            contract: [
                .init(
                    id: self.contractId ?? "",
                    displayName: self.selectedQuote?.productVariant.displayName ?? "",
                    exposureName: L10n.addonFlowSummaryActiveFrom(
                        self.addonOffer?.activationDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    newPremium: self.selectedQuote?.price,
                    currentPremium: self.addonOffer?.currentAddon?.price,
                    documents: self.selectedQuote?.productVariant.documents ?? [],
                    onDocumentTap: { document in
                        changeAddonNavigationVm.document = document
                    },
                    displayItems: self.selectedQuote?.displayItems
                        .map({ .init(title: $0.displayTitle, value: $0.displayValue) }) ?? [],
                    insuranceLimits: [],
                    typeOfContract: nil
                )
            ],
            total: totalPrice ?? .init(amount: 0, currency: "SEK"),
            isAddon: true
        ) {
            Task {
                await self.submitAddons()
            }
            changeAddonNavigationVm.isConfirmAddonPresented = true
        }

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    return ChangeAddonSummaryScreen(changeAddonNavigationVm: .init(input: .init(contractId: "")))
}
