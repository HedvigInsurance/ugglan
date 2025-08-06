import SwiftUI
import hCore
import hCoreUI

struct ConfirmChangesView: View {
    @ObservedObject var intentViewModel: IntentViewModel
    let onButtonTap: () -> Void

    init(
        intentViewModel: IntentViewModel,
        onButtonTap: @escaping () -> Void
    ) {
        self.intentViewModel = intentViewModel
        self.onButtonTap = onButtonTap
    }

    var body: some View {
        VStack(spacing: .padding16) {
            PriceField(
                newPremium: intentViewModel.intent.newCost,
                currentPremium: intentViewModel.intent.currentCost,
                subTitle: L10n.contractAddCoinsuredStartsFrom(
                    intentViewModel.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                )
            )
            .hWithStrikeThroughPrice(setTo: .crossOldPrice)

            hContinueButton {
                onButtonTap()
            }
        }
    }
}
