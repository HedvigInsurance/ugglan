import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSuccessScreen: View {
    var body: some View {
        SuccessScreen(
            successViewTitle: L10n.claimsSuccessTitle,
            successViewBody: L10n.claimsSuccessLabel,
            buttons: .init(
                ghostButton: .init(buttonAction: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                })
            )
        )
    }
}

#Preview{
    SubmitClaimSuccessScreen()
}
