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
                .foregroundColor(hSignalColorNew.amberElement)
                .padding(.top, 254)
                .padding(.bottom, 8)

            Group {
                hText(L10n.embarkUpdateAppTitle, style: .body)
                    .foregroundColor(hTextColorNew.primary)

                hText(L10n.embarkUpdateAppBody, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hTextColorNew.secondary)
            }
            .padding(.horizontal, 32)
        }
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonPrimary {
                    UIApplication.shared.open(Environment.current.appStoreURL)
                    onSelected()
                } content: {
                    hText(L10n.embarkUpdateAppButton, style: .body)
                }
                .padding(.bottom, 4)
                hButton.LargeButtonText {
                    onSelected()
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}
