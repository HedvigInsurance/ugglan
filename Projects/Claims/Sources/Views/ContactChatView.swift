import SwiftUI
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
                hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .standardSmall)
                    .foregroundColor(hTextColor.secondary)
                hText(L10n.ClaimStatus.Contact.Generic.title, style: .standard)
            }
            Spacer()

            Button {
                store.send(.openFreeTextChat)
            } label: {

            }
            .buttonStyle(ChatButtonStyle())
        }
    }
}

struct ChatButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        hCoreUIAssets.chatQuickNav.view
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
}
