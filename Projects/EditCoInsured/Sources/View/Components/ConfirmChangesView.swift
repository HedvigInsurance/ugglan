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
            PriceFieldMultipleRows(
                viewModels: [
                    .init(
                        initialValue: nil,
                        newValue: intentViewModel.intent.currentTotalCost.montlyNet
                    ),
                    .init(
                        initialValue: intentViewModel.intent.newTotalCost.monthlyGross,
                        newValue: intentViewModel.intent.newTotalCost.montlyNet,
                        subTitle: L10n.summaryTotalPriceSubtitle(
                            intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        ),
                        infoButtonDisplayItems: intentViewModel.intent.newCostBreakdown.compactMap({
                            .init(title: $0.displayTitle, value: $0.displayValue)
                        })
                    ),
                ]
            )

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
