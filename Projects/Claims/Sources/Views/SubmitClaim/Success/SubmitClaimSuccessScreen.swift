import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSuccessScreen: View {
    var body: some View {
        SuccessScreen(
            successViewTitle: L10n.claimsSuccessTitle,
            successViewBody: L10n.claimsSuccessLabel,
            successViewButtonAction: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.dissmissNewClaimFlow)
            }
        )
    }
}

#Preview{
    SubmitClaimSuccessScreen()
}
