import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    private let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeTierVm: ChangeTierViewModel,
        changeTierNavigationVm: ChangeTierNavigationViewModel
    ) {
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

        //merge documents for in surance and addons
        var documents = self.selectedQuote?.productVariant?.documents ?? []
        selectedQuote?.addons
            .forEach { addon in
                documents.append(contentsOf: addon.addonVariant.documents)
            }

        contracts.append(
            .init(
                id: currentTier?.id ?? "",
                displayName: displayName ?? "",
                exposureName: activationDate,
                premium: .init(
                    gross: newTotalCost?.gross,
                    net: newTotalCost?.net
                ),
                documentSection: .init(
                    documents: documents,
                    onTap: { [weak changeTierNavigationVm] document in
                        changeTierNavigationVm?.document = document
                    },
                ),
                displayItems: displayItems,
                insuranceLimits: selectedQuote?.productVariant?.insurableLimits ?? [],
                typeOfContract: typeOfContract,
                priceBreakdownItems: selectedQuote?.costBreakdown
                    .map({ item in
                        .init(title: item.title, value: item.value)
                    }) ?? []
            )
        )

        let totalNet: MonetaryAmount = {
            let totalValue =
                contracts
                .reduce(0, { $0 + ($1.premium?.net?.value ?? 0) })
            return .init(amount: totalValue, currency: contracts.first?.premium?.net?.currency ?? "")
        }()

        let totalGross: MonetaryAmount = {
            let totalValue =
                contracts
                .reduce(0, { $0 + ($1.premium?.gross?.value ?? 0) })
            return .init(amount: totalValue, currency: contracts.first?.premium?.gross?.currency ?? "")
        }()

        let vm = QuoteSummaryViewModel(
            contract: contracts,
            activationDate: self.activationDate,
            summaryDataProvider: DirectQuoteSummaryDataProvider(
                intentCost: .init(
                    gross: totalGross,
                    net: totalNet
                )
            ),
            onConfirmClick: { [weak changeTierNavigationVm] in
                changeTierNavigationVm?.vm.commitTier()
                changeTierNavigationVm?.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
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
