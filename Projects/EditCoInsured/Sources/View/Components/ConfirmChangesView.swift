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
            let showCostBreakdown =
                intentViewModel.intent.newTotalCost.net != intentViewModel.intent.currentTotalCost.net
            if showCostBreakdown {
                priceBreakdownView
            }

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

    private var priceBreakdownView: some View {
        PriceFieldMultipleRows(
            viewModels: [
                .init(
                    initialValue: nil,
                    newValue: intentViewModel.intent.currentTotalCost.net ?? .sek(0),
                    title: L10n.pricePreviousPrice
                ),
                .init(
                    initialValue: nil,
                    newValue: intentViewModel.intent.newTotalCost.net ?? .sek(0),
                    title: L10n.priceNewPrice,
                    subTitle: L10n.summaryTotalPriceSubtitle(
                        intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    infoButtonModel: .init(
                        initialValue: intentViewModel.intent.newTotalCost.gross,
                        newValue: intentViewModel.intent.newTotalCost.net ?? .sek(0),
                        infoButtonDisplayItems: intentViewModel.intent.newCostBreakdown.compactMap({
                            .init(title: $0.displayTitle, value: $0.displayValue)
                        })
                    )
                ),
            ]
        )
        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangesView(editCoInsuredNavigation: .init(config: .init()))
}
