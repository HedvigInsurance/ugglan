import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                hTextNew(L10n.claimsSuccessTitle, style: .customTitle)
                    .foregroundColor(hTextColorNew.primary)
                hTextNew(L10n.claimsSuccessLabel, style: .body)
                    .foregroundColor(hTextColorNew.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, UIScreen.main.bounds.size.height / 3.5)
            .padding(.horizontal, 32)
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack(spacing: 8) {
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
            .padding(.horizontal, 16)
        }
    }
}

struct SubmitClaimSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSuccessScreen()
    }
}
