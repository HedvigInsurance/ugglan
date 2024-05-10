import Presentation
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimSuccessScreen: View {
    @EnvironmentObject var router: Router

    var body: some View {
        SuccessScreen(
            successViewTitle: L10n.claimsSuccessTitle,
            successViewBody: L10n.claimsSuccessLabel,
            buttons: .init(
                ghostButton: .init(buttonAction: {
                    router.dismiss()
                })
            )
        )
    }
}

#Preview{
    SubmitClaimSuccessScreen()
}
