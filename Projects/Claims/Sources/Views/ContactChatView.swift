import hCore
import hCoreUI
import SwiftUI

struct ContactChatView: View {
    let store: ClaimsStore
    let id: String

    init(
        store: ClaimsStore,
        id: String
    ) {
        self.store = store
        self.id = id
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                hText(L10n.ClaimStatus.Contact.Generic.title, style: .body1)
            }
            Spacer()

            Button {
                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
            } label: {}
                .buttonStyle(ChatButtonStyle())
        }
    }
}

struct ChatButtonStyle: ButtonStyle {
    func makeBody(configuration _: Configuration) -> some View {
        hCoreUIAssets.chatQuickNav.view
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
    }
}
