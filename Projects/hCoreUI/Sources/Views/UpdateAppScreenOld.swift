import SwiftUI
import hCore
import hGraphQL

public struct UpdateAppScreenOld: View {

    let onSelected: () -> Void

    public init(
        onSelected: @escaping () -> Void
    ) {
        self.onSelected = onSelected
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)

                hText(L10n.embarkUpdateAppTitle, style: .title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)

                hText(L10n.embarkUpdateAppBody, style: .body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hFormAttachToBottom {

            VStack {
                hButton.LargeButtonOutlined {
                    UIApplication.shared.open(Environment.current.appStoreURL)
                    onSelected()
                } content: {
                    hText(L10n.embarkUpdateAppButton, style: .body)
                        .foregroundColor(hTextColorNew.primary)
                }
                .padding(.bottom, 4)
                hButton.LargeButton(type: .primary) {
                    onSelected()
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                        .foregroundColor(hTextColorNew.primary.inverted)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}
