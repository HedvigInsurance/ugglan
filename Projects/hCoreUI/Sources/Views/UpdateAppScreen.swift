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
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                    .foregroundColor(hSignalColor.amberElement)

                VStack {
                    hText(L10n.embarkUpdateAppTitle, style: .body)
                        .foregroundColor(hTextColor.primary)

                    hText(L10n.embarkUpdateAppBody, style: .body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.secondary)
                }
                hButton.MediumButton(type: .primary) {
                    UIApplication.shared.open(Environment.current.appStoreURL)
                    onSelected()
                } content: {
                    hText(L10n.embarkUpdateAppButton, style: .body)
                }
                .fixedSize()
            }
            .padding(.horizontal, 32)
        }
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                onSelected()
            } content: {
                hText(L10n.generalCloseButton, style: .body)
            }
            .padding([.horizontal, .bottom], 16)
        }
    }
}

#Preview{
    UpdateAppScreen(onSelected: {})
}
