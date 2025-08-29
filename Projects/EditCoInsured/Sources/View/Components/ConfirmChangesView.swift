import SwiftUI
import hCore
import hCoreUI

struct ConfirmChangesView: View {
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    init(
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        intentViewModel = editCoInsuredNavigation.intentViewModel
    }

    var body: some View {
        VStack(spacing: .padding16) {
            PriceField(
                viewModel: .init(
                    newPremium: intentViewModel.intent.newTotalCost.montlyNet,
                    currentPremium: intentViewModel.intent.currentTotalCost.montlyNet,
                    subTitle: L10n.summaryTotalPriceSubtitle(
                        intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    infoButtonDisplayItems: intentViewModel.intent.newCostBreakdown.compactMap({
                        .init(title: $0.displayTitle, value: $0.displayValue)
                    })
                )
            )
            .hPriceFieldFormat(.multipleRow)

            hButton(
                .large,
                .primary,
                content: .init(title: L10n.contractAddCoinsuredConfirmChanges),
                {
                    editCoInsuredNavigation.showProgressScreenWithSuccess = true
                    Task {
                        await intentViewModel.performCoInsuredChanges(
                            commitId: intentViewModel.intent.id
                        )
                    }
                }
            )
            .hButtonIsLoading(intentViewModel.isLoading)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangesView(editCoInsuredNavigation: .init(config: .init()))
}
