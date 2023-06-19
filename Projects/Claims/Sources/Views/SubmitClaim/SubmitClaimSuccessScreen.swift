import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                Spacer()
                hTextNew(L10n.claimsSuccessTitle, style: .customTitle)
                    .foregroundColor(hLabelColorNew.primary)
                hTextNew(L10n.claimsSuccessLabel, style: .body)
                    .foregroundColor(hLabelColorNew.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.horizontal, 16)
            VStack(spacing: 8) {
                Spacer()
                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                    store.send(.submitClaimOpenFreeTextChat)
                } content: {
                    hTextNew(L10n.openChat, style: .body)
                }

                hButton.LargeButtonText {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hTextNew(L10n.generalCloseButton, style: .body)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct SubmitClaimSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSuccessScreen()
    }
}
