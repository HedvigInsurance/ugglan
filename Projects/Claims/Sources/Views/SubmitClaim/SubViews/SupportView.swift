import Foundation
import SwiftUI
import hCore
import hCoreUI

struct SupportView: View {
    @EnvironmentObject var router: Router
    let openChat: () -> Void

    var body: some View {
        HStack {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    hText(L10n.submitClaimNeedHelpTitle)
                        .foregroundColor(hTextColor.Translucent.primary)
                    hText(L10n.submitClaimNeedHelpLabel)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.center)
                }
                hButton.MediumButton(type: .primary) {
                    router.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        openChat()
                    }
                } content: {
                    hText(L10n.CrossSell.Info.faqChatButton)
                }
            }
            .padding(.top, .padding32)
            .padding(.bottom, .padding56)
        }
        .frame(maxWidth: .infinity)
        .background(hSurfaceColor.Opaque.primary)
    }
}
struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return SupportView(openChat: {})
    }
}
