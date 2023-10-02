import SwiftUI
import hCore
import hCoreUI

struct PlaybackFailedView: View {
    let buttonAction: () -> Void

    var body: some View {
        VStack {
            HStack {
                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                hText(L10n.ClaimStatusDetail.InfoError.title, style: .headline)
            }
            .padding(.vertical, 18)

            hText(L10n.ClaimStatusDetail.InfoError.body, style: .subheadline)
                .foregroundColor(hTextColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Spacer()
                .frame(height: 24)

            Button {
                buttonAction()
            } label: {
                hText(L10n.ClaimStatusDetail.InfoError.button, style: .subheadline)
                    .foregroundColor(hTextColor.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .frame(height: 36)
            .cornerRadius(6)
            .background(hTintColorOld.yellowOne)
            .padding(.bottom, 16)

        }
        .padding(.horizontal, 24)
        .background(hTintColorOld.yellowTwo)
        .cornerRadius(.defaultCornerRadius)
        .border(hBorderColor.opaqueFour, width: 0.5)
    }
}
