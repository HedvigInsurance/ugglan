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

        //merge documents for insurance and addons
        let documents =
            (selectedQuote?.productVariant?.documents ?? [])
            + (selectedQuote?.addons.flatMap(\.addonVariant.documents) ?? [])

        let contracts = [
            QuoteSummaryViewModel.ContractInfo(
                id: currentTier?.id ?? "",
                displayName: displayName ?? "",
                exposureName: activationDate,
                premium: newTotalCost,
                documentSection: .init(
                    documents: documents,
                    onTap: { [weak changeTierNavigationVm] document in
                        changeTierNavigationVm?.document = document
                    },
                ),
                displayItems: displayItems,
                insuranceLimits: selectedQuote?.productVariant?.insurableLimits ?? [],
                typeOfContract: typeOfContract,
                priceBreakdownItems: (selectedQuote?.costBreakdown ?? [])
                    .map { item in .init(title: item.title, value: item.value, crossDisplayTitle: item.isCrossed) }
            )
        ]

        let totalPremium = contracts.compactMap(\.premium).sum()

        let vm = QuoteSummaryViewModel(
            contract: contracts,
            activationDate: self.activationDate,
            totalPrice: .comparison(old: totalPremium.gross, new: totalPremium.net),
            onConfirmClick: { [weak changeTierNavigationVm] in
                changeTierNavigationVm?.vm.commitTier()
                changeTierNavigationVm?.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
            }
        )

        return vm
    }
}
@available(iOS 17.0, *)
#Preview {
    let changeTierVm = ChangeTierViewModel(
        changeTierInput: .contractWithSource(
            data: .init(source: .betterCoverage, contractId: "contractId")
        )
    )
    let changeTierNavigationVm = ChangeTierNavigationViewModel(
        router: Router(),
        vm: changeTierVm
    )
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })

    return ChangeTierSummaryScreen(
        changeTierVm: changeTierVm,
        changeTierNavigationVm: changeTierNavigationVm
    )
}
