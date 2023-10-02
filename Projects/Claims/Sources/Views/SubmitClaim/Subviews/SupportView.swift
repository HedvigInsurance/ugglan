import Foundation
import SwiftUI
import hCore
import hCoreUI

struct SupportView: View {
    @PresentableStore var store: SubmitClaimStore

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                hText(L10n.submitClaimNeedHelpTitle)
                    .foregroundColor(hTextColor.primaryTranslucent)
                hText(L10n.submitClaimNeedHelpLabel)
                    .foregroundColor(hTextColor.secondary)
            }
            hButton.MediumButton(type: .primary) {
                store.send(.dissmissNewClaimFlow)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    store.send(.submitClaimOpenFreeTextChat)
                }
            } content: {
                hText(L10n.CrossSell.Info.faqChatButton)
            }
            .fixedSize(horizontal: true, vertical: false)

        }
    }
}
struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SupportView()
    }
}
