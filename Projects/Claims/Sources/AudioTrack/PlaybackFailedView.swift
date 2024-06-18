import SwiftUI
import hCore
import hCoreUI

struct PlaybackFailedView: View {
    let buttonAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Image(uiImage: hCoreUIAssets.warningTriangleOutlined.image)
                hText(L10n.ClaimStatusDetail.InfoError.title, style: .headline)
            }
            .padding(.vertical, 18)

            hText(L10n.ClaimStatusDetail.InfoError.body, style: .subheadline)
                .foregroundColor(hTextColor.Opaque.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Spacer()
                .frame(height: 24)

            Button {
                buttonAction()
            } label: {
                hSection {
                    hText(L10n.ClaimStatusDetail.InfoError.button, style: .subheadline)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .padding(.vertical, .padding8)
                }
                .sectionContainerStyle(.transparent)
            }
            .frame(height: 36)
            .cornerRadius(6)
            .background(hHighlightColor.Yellow.fillThree)
            .padding(.bottom, .padding16)

        }
        .padding(.horizontal, .padding24)
        .background(hBlurColor.blurTwo)
        .cornerRadius(.cornerRadiusL)
        .border(hBorderColor.secondary, width: 0.5)
    }
}
