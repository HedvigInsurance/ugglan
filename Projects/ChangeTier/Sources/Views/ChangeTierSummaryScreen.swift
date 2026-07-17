import SwiftUI
import hCore
import hCoreUI

struct ChangeTierSummaryScreen: View {
    private let changeTierNavigationVm: ChangeTierNavigationViewModel

    init(changeTierNavigationVm: ChangeTierNavigationViewModel) {
        self.changeTierNavigationVm = changeTierNavigationVm
    }

    var body: some View {
        QuoteSummaryScreen(
            quoteSummary: changeTierNavigationVm.vm.asQuoteSummary(),
            onDocumentTap: { [weak changeTierNavigationVm] in changeTierNavigationVm?.document = $0 }
        ) { [weak changeTierNavigationVm] in
            changeTierNavigationVm?.vm.commitTier()
            changeTierNavigationVm?.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
        }
    }
}

extension ChangeTierViewModel {
    func asQuoteSummary() -> QuoteSummary {
        let displayItems: [QuoteDisplayItem] =
            selectedQuote?.displayItems.map { .init(title: $0.title, value: $0.value) } ?? []
        let activationDate = L10n.changeAddressActivationDate(activationDate?.displayDateDDMMMYYYYFormat ?? "")

        //merge documents for insurance and addons
        let documents =
            (selectedQuote?.productVariant?.documents ?? [])
            + (selectedQuote?.addons.flatMap(\.addonVariant.documents) ?? [])

        let contracts = [
            QuoteSummary.ContractInfo(
                id: currentTier?.id ?? "",
                title: displayName ?? "",
                subtitle: activationDate,
                premium: newTotalCost,
                documents: documents,
                displayItems: displayItems,
                insuranceLimits: selectedQuote?.productVariant?.insurableLimits ?? [],
                typeOfContract: typeOfContract,
                priceBreakdownItems: (selectedQuote?.costBreakdown ?? [])
                    .map { item in .init(title: item.title, value: item.value, crossDisplayTitle: item.isCrossed) }
            )
        ]

        let totalPremium = contracts.compactMap(\.premium).sum()

        return QuoteSummary(
            contracts: contracts,
            activationDate: self.activationDate,
            totalPrice: .comparison(old: totalPremium.gross, new: totalPremium.net)
        )
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
        router: NavigationRouter(),
        vm: changeTierVm
    )
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })

    return ChangeTierSummaryScreen(
        changeTierNavigationVm: changeTierNavigationVm
    )
}
