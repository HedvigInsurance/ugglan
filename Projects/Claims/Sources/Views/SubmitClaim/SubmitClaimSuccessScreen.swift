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
                    .foregroundColor(hLabelColorNew.primary)
                    .padding(.top, 264)
                hTextNew(L10n.claimsSuccessLabel, style: .body)
                    .foregroundColor(hLabelColorNew.secondary)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)
            }
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                    store.send(.submitClaimOpenFreeTextChat)
                } content: {
                    HStack {
                        hTextNew(L10n.openChat, style: .body)
                    }
                }

                hButton.LargeButtonText {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    HStack {
                        hTextNew(L10n.generalCloseButton, style: .body)
                    }
                }
            }
            .padding([.leading, .trailing], 16)
            .padding(.bottom, 32)
        }
    }
}

struct SubmitClaimSuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSuccessScreen()
    }
}
