import Home
import SwiftUI
import hCore
import hCoreUI

struct ContactChatView: View {
    let store: ClaimsStore
    let id: String
    let status: String

    @EnvironmentObject var homeVm: HomeNavigationViewModel

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
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .standardSmall)
                    .foregroundColor(hTextColor.Opaque.secondary)
                hText(L10n.ClaimStatus.Contact.Generic.title, style: .body1)
            }
            Spacer()

            Button {
                NotificationCenter.default.post(name: .openChat, object: ChatTopicWrapper(topic: nil, onTop: true))
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
            .frame(width: 40, height: 40)
    }
}
