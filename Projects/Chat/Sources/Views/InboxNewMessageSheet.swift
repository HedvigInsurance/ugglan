import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct InboxNewMessageSheet: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                hSection {
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(L10n.chatConversationQuestionTitle, style: .body1)
                            hText(L10n.inboxNewMessageSupportDescription, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap(openSupport)
                }
                hSection {
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(L10n.honestyPledgeHeader, style: .body1)
                            hText(L10n.inboxNewMessageClaimDescription, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap(openClaim)
                }
            }
            .padding(.top, .padding32)
            .padding(.top, .padding4)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .secondary,
                    content: .init(title: L10n.generalCloseButton)
                ) { dismiss() }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .hFormContentPosition(.compact)
        .hFormIgnoreBottomPadding
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
            vc.navigationController?.navigationBar.backgroundColor = .red
        }
    }

    private func openSupport() {
        dismiss()
        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
    }

    private func openClaim() {
        dismiss()
        NotificationCenter.default.post(name: .openDeepLink, object: DeepLink.submitClaim.url)
    }
}

#Preview {
    InboxNewMessageSheet()
}
