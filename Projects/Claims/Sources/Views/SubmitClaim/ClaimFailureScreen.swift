import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimFailureScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        hForm {
            VStack {
                Spacer()
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColorNew.amberElement)
                    .padding(.bottom, 8)

                hText(L10n.HomeTab.errorTitle, style: .body)
                    .foregroundColor(hTextColorNew.primary)

                hText(L10n.HomeTab.errorBody, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hTextColorNew.secondary)
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonPrimary {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                }
                .padding(.bottom, 4)

                hButton.LargeButtonText {
                    store.send(.dissmissNewClaimFlow)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        store.send(.submitClaimOpenFreeTextChat)
                    }
                } content: {
                    hText(L10n.openChat, style: .body)
                }
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}
