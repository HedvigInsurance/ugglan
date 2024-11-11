import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct SupportView: View {
    @PresentableStore var store: SubmitClaimStore
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    let openChat: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                hText(L10n.submitClaimNeedHelpTitle)
                    .foregroundColor(hTextColor.Translucent.primary)
                hText(L10n.submitClaimNeedHelpLabel)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .multilineTextAlignment(.center)
            }
            hButton.MediumButton(type: .primary) {
                claimsNavigationVm.router.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    openChat()
                }
            } content: {
                hText(L10n.CrossSell.Info.faqChatButton)
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}
struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return SupportView(openChat: {})
    }
}
