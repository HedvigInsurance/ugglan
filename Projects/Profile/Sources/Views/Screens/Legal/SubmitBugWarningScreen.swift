import SwiftUI
import hCore
import hCoreUI

/// The submit-bug warning, with its "write to us" part linked to a new conversation.
struct SubmitBugWarningScreen: View {
    let onContinue: () -> Void
    let onCancel: () -> Void
    let onWriteToUs: () -> Void

    private static let newConversationLink = "https://hedvig-internal/new-conversation"

    /// The copy is split into three keys so the linked middle part needs no matching against the full text.
    private var warningText: Markdown {
        let beforeLink = L10n.appInfoSubmitBugWarningWithChatLink1
        let link = L10n.appInfoSubmitBugWarningWithChatLink2
        let afterLink = L10n.appInfoSubmitBugWarningWithChatLink3
        return "\(beforeLink) [\(link)](\(Self.newConversationLink)) \(afterLink)"
    }

    var body: some View {
        hForm {}
            .hFormContentPosition(.compact)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding24) {
                        MarkdownView(
                            config: .init(
                                text: warningText,
                                fontStyle: .body1,
                                color: hTextColor.Opaque.primary,
                                linkColor: hTextColor.Opaque.primary,
                                linkUnderlineStyle: .single,
                                textAlignment: .center,
                                isSelectable: false
                            ) { url in
                                if url.absoluteString == Self.newConversationLink {
                                    onWriteToUs()
                                }
                            }
                        )
                        VStack(spacing: .padding8) {
                            hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                                onContinue()
                            }
                            hButton(.large, .ghost, content: .init(title: L10n.alertCancel)) {
                                onCancel()
                            }
                        }
                    }
                    .padding(.top, .padding24)
                }
                .sectionContainerStyle(.transparent)
            }
    }
}

#Preview {
    SubmitBugWarningScreen(onContinue: {}, onCancel: {}, onWriteToUs: {})
}
