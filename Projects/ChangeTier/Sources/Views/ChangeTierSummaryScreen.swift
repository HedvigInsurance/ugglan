import SwiftUI
import hCore
import hCoreUI
import hGraphQL

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
    }
}

extension ChangeTierViewModel {
    func asQuoteSummaryViewModel(changeTierNavigationVm: ChangeTierNavigationViewModel) -> QuoteSummaryViewModel {
        let displayItems: [QuoteDisplayItem] =
            self.selectedQuote?.displayItems.map({ .init(title: $0.title, value: $0.value) }) ?? []
        let activationDate = L10n.changeAddressActivationDate(activationDate?.displayDateDDMMMYYYYFormat ?? "")
        var contracts: [QuoteSummaryViewModel.ContractInfo] = []
        contracts.append(
            .init(
                id: self.currentTier?.id ?? "",
                displayName: self.displayName ?? "",
                exposureName: activationDate,
                newPremium: self.newPremium,
                currentPremium: self.currentPremium,
                documents: self.selectedQuote?.productVariant?.documents ?? [],
                onDocumentTap: { [weak changeTierNavigationVm] document in
                    changeTierNavigationVm?.document = document
                },
                displayItems: displayItems,
                insuranceLimits: self.selectedQuote?.productVariant?.insurableLimits ?? [],
                typeOfContract: self.typeOfContract
            )
        )
        for addon in self.selectedQuote?.addons ?? [] {
            contracts.append(
                .init(
                    id: addon.addonId,
                    displayName: addon.displayName,
                    exposureName: activationDate,
                    newPremium: addon.premium,
                    currentPremium: addon.previousPremium,
                    documents: addon.addonVariant.documents,
                    onDocumentTap: { [weak changeTierNavigationVm] document in
                        changeTierNavigationVm?.document = document
                    },
                    displayItems: addon.displayItems.compactMap({ .init(title: $0.title, value: $0.value) }),
                    insuranceLimits: addon.addonVariant.insurableLimits,
                    typeOfContract: nil,
                    onInfoClick: {
                        changeTierNavigationVm.isInfoViewPresented = .init(
                            title: addon.displayName,
                            description: L10n.movingFlowTravelAddonSummaryDescription
                        )
                    }
                )
            )
        }
        let premium: MonetaryAmount = {
            let quotePremium = self.newPremium?.value ?? 0
            let addonsPremium: Float =
                self.selectedQuote?.addons
                .reduce(
                    0,
                    { partialResult, addon in
                        partialResult + addon.premium.value
                    }
                ) ?? 0
            return .init(amount: quotePremium + addonsPremium, currency: self.newPremium?.currency ?? "")
        }()
        let vm = QuoteSummaryViewModel(
            contract: contracts,
            total: premium,
            onConfirmClick: {
                self.commitTier()
                changeTierNavigationVm.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
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
