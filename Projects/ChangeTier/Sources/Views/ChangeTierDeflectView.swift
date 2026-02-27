import SwiftUI
import hCore
import hCoreUI

struct ChangeTierDeflectView: View {
    @EnvironmentObject var router: NavigationRouter
    let title: String
    let message: String

    var body: some View {
        hForm {
            hRow {
                hText(message)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .hFormTitle(title: .init(.small, .body2, title, alignment: .leading))
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    iUnderstandButton
                    contactUsButton
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    var contactUsButton: some View {
        hButton(.large, .ghost, content: .init(title: L10n.CrossSell.Info.faqChatButton)) {
            router.dismiss()
            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
        }
    }

    var iUnderstandButton: some View {
        hButton(.large, .primary, content: .init(title: L10n.terminationFlowIUnderstandText)) {
            router.dismiss()
        }
    }
}

#Preview {
    ChangeTierDeflectView(
        title: "How to change back to your previous coverage",
        message:
            "To update your coverage, your car first needs to be registered as active with Transportstyrelsen. Once that’s done, your insurance will be updated automatically."
    )
    .environmentObject(NavigationRouter())
}
