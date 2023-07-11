import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ClaimFailureScreen: View {
    @PresentableStore var store: SubmitClaimStore

    public init() {}

    public var body: some View {
        hForm {
            Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                .foregroundColor(hSignalColorNew.amberElement)
                .padding(.top, 254)
                .padding(.bottom, 8)

            Group {
                hTextNew(L10n.HomeTab.errorTitle, style: .body)
                    .foregroundColor(hTextColorNew.primary)

                hTextNew(L10n.HomeTab.errorBody, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hTextColorNew.secondary)
            }
            .padding(.horizontal, 32)
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hTextNew(L10n.generalCloseButton, style: .body)
                }
                .padding(.bottom, 4)

                hButton.LargeButtonText {
                    store.send(.dissmissNewClaimFlow)
                    store.send(.submitClaimOpenFreeTextChat)
                } content: {
                    hTextNew(L10n.openChat, style: .body)
                }
            }
            .padding([.leading, .trailing, .bottom], 16)
        }
    }
}
