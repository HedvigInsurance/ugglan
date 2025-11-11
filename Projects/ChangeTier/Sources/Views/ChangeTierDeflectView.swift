import SwiftUI
import hCore
import hCoreUI

struct ChangeTierDeflectView: View {
    @EnvironmentObject var router: Router
    let title: String
    let message: String

    var body: some View {
        hForm {
            hText(message)
                .padding(.top, .padding16)
                .foregroundColor(hTextColor.Translucent.secondary)
        }
        .hFormTitle(
            title: .init(.small, .body2, title, alignment: .leading),
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(.large, .primary, content: .init(title: L10n.terminationFlowIUnderstandText)) {
                        router.dismiss()
                    }
                    hButton(.large, .ghost, content: .init(title: L10n.CrossSell.Info.faqChatButton)) {
                        router.dismiss()
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview {
    ChangeTierDeflectView(
        title: "How to change back to your previous coverage",
        message:
            "To update your coverage, your car first needs to be registered as active with Transportstyrelsen. Once that’s done, your insurance will be updated automatically."
    )
    .environmentObject(Router())
}
