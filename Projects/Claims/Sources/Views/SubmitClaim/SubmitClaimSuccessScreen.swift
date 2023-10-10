import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSuccessScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                hText(L10n.claimsSuccessTitle, style: .title1)
                    .foregroundColor(hTextColor.primary)
                hText(L10n.claimsSuccessLabel, style: .body)
                    .foregroundColor(hTextColor.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, UIScreen.main.bounds.size.height / 3.5)
            .padding(.horizontal, 32)
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .primary) {
                    store.send(.dissmissNewClaimFlow)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        store.send(.submitClaimOpenFreeTextChat)
                    }
                } content: {
                    hText(L10n.openChat, style: .body)
                }

                hButton.LargeButton(type: .ghost) {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
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
