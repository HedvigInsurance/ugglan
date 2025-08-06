import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var changeTierVm: ChangeTierViewModel
    let quoteSummaryVm: QuoteSummaryViewModel
    @ObservedObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        changeTierVm: ChangeTierViewModel,
        changeTierNavigationVm: ChangeTierNavigationViewModel
    ) {
        self.changeTierVm = changeTierVm
        self.changeTierNavigationVm = changeTierNavigationVm
        quoteSummaryVm = changeTierVm.asQuoteSummaryViewModel(changeTierNavigationVm: changeTierNavigationVm)
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
            .hAccessibilityWithoutCombinedElements
    }
}

extension ChangeTierViewModel {
    func asQuoteSummaryViewModel(changeTierNavigationVm: ChangeTierNavigationViewModel) -> QuoteSummaryViewModel {
        let displayItems: [QuoteDisplayItem] =
            selectedQuote?.displayItems.map { .init(title: $0.title, value: $0.value) } ?? []
        let activationDate = L10n.changeAddressActivationDate(activationDate?.displayDateDDMMMYYYYFormat ?? "")
        var contracts: [QuoteSummaryViewModel.ContractInfo] = []
        contracts.append(
            .init(
                id: currentTier?.id ?? "",
                displayName: displayName ?? "",
                exposureName: activationDate,
                netPremium: newPremium,
                grossPremium: currentPremium,
                documents: self.selectedQuote?.productVariant?.documents ?? [],
                onDocumentTap: { [weak changeTierNavigationVm] document in
                    changeTierNavigationVm?.document = document
                },
                displayItems: displayItems,
                insuranceLimits: selectedQuote?.productVariant?.insurableLimits ?? [],
                typeOfContract: typeOfContract,
                discountDisplayItems: []
            )
        )
        for addon in selectedQuote?.addons ?? [] {
            contracts.append(
                .init(
                    id: addon.addonId,
                    displayName: addon.displayName,
                    exposureName: activationDate,
                    netPremium: addon.premium,
                    grossPremium: addon.previousPremium,
                    documents: addon.addonVariant.documents,
                    onDocumentTap: { [weak changeTierNavigationVm] document in
                        changeTierNavigationVm?.document = document
                    },
                    displayItems: addon.displayItems.compactMap { .init(title: $0.title, value: $0.value) },
                    insuranceLimits: [],
                    typeOfContract: nil,
                    isAddon: true,
                    discountDisplayItems: []
                )
            )
        }
        let totalNet: MonetaryAmount = {
            let totalValue =
                contracts
                .reduce(0, { $0 + ($1.netPremium?.value ?? 0) })
            return .init(amount: totalValue, currency: contracts.first?.netPremium?.currency ?? "")
        }()

        let vm = QuoteSummaryViewModel(
            contract: contracts,
            activationDate: self.activationDate,
            summaryDataProvider: DirectQuoteSummaryDataProvider(
                intentCost: .init(
                    totalGross: self.currentPremium!,
                    totalNet: totalNet
                )
            ),
            onConfirmClick: {
                changeTierNavigationVm.isConfirmTierPresented = true
            }
        )

        return vm
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let changeTierInput: ChangeTierInput = .contractWithSource(
        data: .init(source: .betterCoverage, contractId: "contractId")
    )
    let changeTierVm = ChangeTierViewModel(changeTierInput: changeTierInput)
    return ChangeTierSummaryScreen(
        changeTierVm: changeTierVm,
        changeTierNavigationVm: .init(router: Router(), vm: changeTierVm) {}
    )
}
