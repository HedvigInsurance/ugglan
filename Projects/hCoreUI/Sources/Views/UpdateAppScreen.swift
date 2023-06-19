import SwiftUI
import hCore
import hGraphQL

public struct UpdateAppScreen: View {
    let onSelected: () -> Void

    public init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }

    public var body: some View {
        hForm {
            Image(uiImage: hCoreUIAssets.warningFilledTriangle.image)
                .foregroundColor(hLabelColorNew.warning)
                .padding(.top, 254)
                .padding(.bottom, 8)

            Group {
                hTextNew(L10n.embarkUpdateAppTitle, style: .body)
                    .foregroundColor(hLabelColorNew.primary)

                hTextNew(L10n.embarkUpdateAppBody, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hLabelColorNew.secondary)
            }
            .padding(.horizontal, 32)
        }
        .hUseNewStyle
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonFilled {
                    UIApplication.shared.open(Environment.current.appStoreURL)
                    onSelected()
                } content: {
                    hTextNew(L10n.embarkUpdateAppButton, style: .body)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonText {
                    onSelected()
                } content: {
                    hTextNew(L10n.generalCloseButton, style: .body)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}
