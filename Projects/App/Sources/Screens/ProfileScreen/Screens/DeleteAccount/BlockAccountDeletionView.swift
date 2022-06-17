import SwiftUI
import hCore
import hCoreUI

struct BlockAccountDeletionView: View {
    @PresentableStore var store: UgglanStore

    var body: some View {
        VStack {
            hText(L10n.DeleteAccount.ongoingClaimsTitle, style: .title2)
                .foregroundColor(hLabelColor.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)

            hText(
                L10n.DeleteAccount.ongoingClaimsDescription,
                style: .callout
            )
            .foregroundColor(hLabelColor.secondary)
            .padding(.leading, 16)
            .padding(.trailing, 48)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            hButton.LargeButtonOutlined {
                store.send(.openChat)
            } content: {
                HStack(spacing: 10) {
                    hCoreUIAssets.chat.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)

                    hText(L10n.MovingUwFailure.buttonText, style: .body)
                        .foregroundColor(hLabelColor.primary)
                }
            }
            .padding()
        }
    }
}

struct BlockAccountDeletionView_Previews: PreviewProvider {
    static var previews: some View {
        BlockAccountDeletionView()
    }
}
