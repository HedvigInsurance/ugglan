import SwiftUI
import hCore
import hCoreUI

struct ContactChatView: View {
    let store: HomeStore
    
    init(store: HomeStore) {
        self.store = store
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                hText(L10n.ClaimStatus.Contact.Generic.subtitle, style: .caption1)
                    .foregroundColor(hLabelColor.secondary)
                hText(L10n.ClaimStatus.Contact.Generic.title, style: .callout)
            }
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(hBackgroundColor.primary)
                    .frame(width: 40, height: 40)

                hCoreUIAssets.chatSolid.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 19)
            }
            .onTapGesture {
                store.send(.openFreeTextChat)
            }
        }
        .padding(16)
    }
}
