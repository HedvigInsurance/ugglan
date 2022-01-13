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
                .foregroundColor(hLabelColor.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            Spacer()
                .frame(height: 24)

            Button {
                buttonAction()
            } label: {
                hText(L10n.ClaimStatusDetail.InfoError.button, style: .subheadline)
                    .foregroundColor(hLabelColor.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .frame(height: 36)
            .cornerRadius(6)
            .background(hTintColor.yellowOne)
            .padding(.bottom, 16)

        }
        .padding(.horizontal, 24)
        .background(hTintColor.yellowTwo)
        .cornerRadius(.defaultCornerRadius)
        .border(hSeparatorColor.separator, width: 0.5)
    }
}
