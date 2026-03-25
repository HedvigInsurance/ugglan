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
                        editCoInsuredNavigation.showProgressScreenWithSuccess = true
                        Task {
                            await intentViewModel.performCoInsuredChanges(
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
    return ConfirmChangesView(editCoInsuredNavigation: .init(config: .init(stakeHolderType: .coInsured)))
}
