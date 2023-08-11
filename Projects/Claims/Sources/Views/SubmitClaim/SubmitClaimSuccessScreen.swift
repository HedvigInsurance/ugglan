import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 0) {
                Image(uiImage: hCoreUIAssets.checkmarkSmall.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColorNew.greenElement)
                    .padding(.bottom, 16)
                hTextNew(L10n.claimsSuccessTitle, style: .body)
                    .foregroundColor(hTextColorNew.primaryTranslucent)
                hTextNew(L10n.claimsSuccessLabel, style: .body)
                    .foregroundColor(hTextColorNew.secondaryTranslucent)
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
