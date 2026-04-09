import Foundation
import SwiftUI
import hCore
import hCoreUI

struct SupportView: View {
    @EnvironmentObject var router: NavigationRouter
    let openChat: () -> Void

    var body: some View {
        HStack {
            VStack(spacing: .padding24) {
                VStack(spacing: 0) {
                    hText(L10n.submitClaimNeedHelpTitle)
                        .foregroundColor(hTextColor.Translucent.primary)
                    hText(L10n.submitClaimNeedHelpLabel)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.center)
                }
                .accessibilityElement(children: .combine)
                hButton(
                    .medium,
                    .primary,
                    content: .init(title: L10n.CrossSell.Info.faqChatButton),
                    {
                        router.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            openChat()
                        }
                    }
                )
            }
            .padding(.top, .padding32)
            .padding(.bottom, .padding56)
        }
        .frame(maxWidth: .infinity)
        .background(hSurfaceColor.Opaque.primary)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    return SupportView(openChat: {})
}
