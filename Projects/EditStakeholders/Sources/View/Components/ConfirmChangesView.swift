import SwiftUI
import hCore
import hCoreUI

struct ConfirmChangesView: View {
    @ObservedObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    init(
        editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    ) {
        self.editStakeholdersNavigation = editStakeholdersNavigation
        intentViewModel = editStakeholdersNavigation.intentViewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            if intentViewModel.showPriceBreakdown {
                priceBreakdownView
            }
            if let intent = intentViewModel.intent {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.contractAddCoinsuredConfirmChanges),
                    {
                        editStakeholdersNavigation.showProgressScreenWithSuccess = true
                        Task {
                            await intentViewModel.performStakeholderChanges(
                                commitId: intent.id
                            )
                        }
                    }
                )
                .hButtonIsLoading(intentViewModel.isLoading)
            }
        }
    }

    @ViewBuilder
    private var priceBreakdownView: some View {
        if let intent = intentViewModel.intent {
            PriceFieldMultipleRows(
                viewModels: [
                    .init(
                        initialValue: nil,
                        newValue: intent.currentTotalCost.net,
                        title: L10n.pricePreviousPrice
                    ),
                    .init(
                        initialValue: nil,
                        newValue: intent.newTotalCost.net,
                        title: L10n.priceNewPrice,
                        subTitle: L10n.summaryTotalPriceSubtitle(
                            intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        ),
                        infoButtonModel: .init(
                            initialValue: intent.newTotalCost.gross,
                            newValue: intent.newTotalCost.net,
                            infoButtonDisplayItems: intent.newCostBreakdown.compactMap({
                                .init(title: $0.displayTitle, value: $0.displayValue)
                            })
                        )
                    ),
                ]
            )
            .hWithStrikeThroughPrice(setTo: .crossOldPrice)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangesView(editStakeholdersNavigation: .init(config: .init(stakeholderType: .coInsured)))
}
