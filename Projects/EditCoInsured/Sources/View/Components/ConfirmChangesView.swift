import SwiftUI
import hCore
import hCoreUI

struct ConfirmChangesView: View {
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var intentViewModel: IntentViewModel

    public init(
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.editCoInsuredNavigation = editCoInsuredNavigation
        self.intentViewModel = editCoInsuredNavigation.intentViewModel
    }

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                PriceField(
                    newPremium: intentViewModel.intent.newPremium,
                    currentPremium: intentViewModel.intent.currentPremium,
                    subTitle: L10n.contractAddCoinsuredStartsFrom(
                        intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    )
                )
                .hWithStrikeThroughPrice(setTo: .crossOldPrice)

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
        .sectionContainerStyle(.transparent)
    }
}
