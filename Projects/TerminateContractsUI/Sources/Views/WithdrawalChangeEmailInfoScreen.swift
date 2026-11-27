import SwiftUI
import hCore
import hCoreUI

/// Explains that the email a withdrawal confirmation is sent to is changed from the member's contact info, and
/// opens email editing from the link in the body.
struct WithdrawalChangeEmailInfoScreen: View {
    @Environment(NavigationRouter.self) var router

    var body: some View {
        hForm {}
            .hFormContentPosition(.compact)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        hCoreUIAssets.infoFilled.view
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(hSignalColor.Blue.element)
                            .accessibilityHidden(true)

                        VStack(spacing: 0) {
                            hText(L10n.terminationFlowWithdrawalChangeEmailTitle)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)
                            MarkdownView(
                                config: .init(
                                    text: bodyMarkdown,
                                    fontStyle: .body1,
                                    color: hTextColor.Translucent.secondary,
                                    linkColor: hTextColor.Opaque.primary,
                                    linkUnderlineStyle: .single,
                                    textAlignment: .center,
                                    isSelectable: false
                                ) { _ in
                                    openEditEmail()
                                }
                            )
                            // The link is only a few words of the text view, so a VoiceOver double tap on the
                            // body wouldn't hit it: make the whole body the link.
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(bodyAccessibilityLabel)
                            .accessibilityAddTraits(.isLink)
                            .accessibilityHint(L10n.voiceoverDoubleClickTo + " " + L10n.voiceoverEdit)
                            .accessibilityAction { openEditEmail() }
                        }
                        .padding(.horizontal, .padding32)

                        hCloseButton {
                            router.dismiss()
                        }
                        .padding(.top, .padding40)
                    }
                    .padding(.top, .padding32)
                }
                .sectionContainerStyle(.transparent)
            }
    }

    /// The body with its link word ("here") made a link. The URL itself is unused: tapping it opens email editing.
    private var bodyMarkdown: Markdown {
        L10n.terminationFlowWithdrawalChangeEmailBody1(
            "[\(L10n.terminationFlowWithdrawalChangeEmailBody2)](https://link.hedvig.com/contact-info)"
        )
    }

    /// The body as plain text.
    private var bodyAccessibilityLabel: String {
        L10n.terminationFlowWithdrawalChangeEmailBody1(L10n.terminationFlowWithdrawalChangeEmailBody2)
    }

    private func openEditEmail() {
        router.dismiss()
        // The email sheet is presented by the app on top of everything, so it opens over the flow. Once saved,
        // `.memberEmailUpdated` is posted and the summary shows the new email.
        NotificationCenter.default.post(name: .openEditEmail, object: nil)
    }
}

#Preview {
    WithdrawalChangeEmailInfoScreen()
        .environment(NavigationRouter())
}
