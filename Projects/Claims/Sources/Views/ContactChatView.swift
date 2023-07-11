import SwiftUI
import hAnalytics
import hCore
import hCoreUI

struct ContactChatView: View {
    let store: ClaimsStore
    let id: String
    let status: String

    init(
        store: ClaimsStore,
        id: String,
        status: String
    ) {
        self.store = store
        self.id = id
        self.status = status
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .caption1)
                    .foregroundColor(hLabelColor.secondary)
                hText(L10n.ClaimStatus.Contact.Generic.title, style: .callout)
            }
            Spacer()

            Button {
                store.send(.openFreeTextChat)
            } label: {

            }
            .buttonStyle(ChatButtonStyle())
            .trackOnTap(
                hAnalyticsEvent.claimDetailClickOpenChat(
                    claimId: id,
                    claimStatus: status
                )
            )
        }
        .padding(.top, 12)
        .padding([.bottom, .horizontal], 16)
    }
}

struct ChatButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hBackgroundColor.primary)
                .frame(width: 40, height: 40)

            hCoreUIAssets.chatQuickNav.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 23, height: 19)
        }
    }
}
