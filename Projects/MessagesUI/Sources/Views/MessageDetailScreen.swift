import AppStateContainer
import MessagesCore
import SwiftUI
import hCore
import hCoreUI

struct MessageDetailScreen: View {
    let messageId: String
    @AppObservedObject private var store: MessagesStore

    var body: some View {
        if let message = store.message(with: messageId) {
            MessageDetailContent(message: message)
                .task { await store.markAsRead(messageId: messageId) }
        } else if case .loaded = store.state {
            GenericErrorView(formPosition: .center)
        } else {
            // Opened before the inbox has loaded, e.g. from a preview or a future deep link.
            DotsActivityIndicator(.standard)
                .task {
                    if store.state.needsLoading { await store.fetchMessages() }
                }
        }
    }
}

private struct MessageDetailContent: View {
    let message: InboxMessage

    var body: some View {
        MessagesScreenLayout(title: message.channel.detailTitle) {
            VStack(alignment: .leading, spacing: .padding24) {
                hText(message.subject, style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, .padding16)
                senderRow
                    .padding(.horizontal, .padding16)
                if message.channel == .email {
                    InfoCard(
                        title: L10n.MessagesInbox.linksDisabledTitle,
                        text: L10n.MessagesInbox.linksDisabledBody,
                        type: .info
                    )
                    .padding(.horizontal, .padding16)
                }
                MessagesCard {
                    messageBody
                        .padding(.horizontal, .padding24)
                        .padding(.vertical, .padding24 + .padding8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, .padding32)
        }
    }

    private var senderRow: some View {
        HStack(spacing: .padding16) {
            HedvigAvatar()
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    hText(message.sender, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                    hText(" · \(message.senderAddress)", style: .body1)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                hText(message.receivedAtLabel, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        // Spelled out so VoiceOver skips the " · " separator and never reads the truncated address.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            [message.sender, message.senderAddress, message.receivedAtLabel].joined(separator: ", ")
        )
    }

    @ViewBuilder
    private var messageBody: some View {
        if let html = message.htmlBody {
            EmailWebView(html: html)
        } else {
            hText(message.textBody ?? message.preview, style: .body1)
                .foregroundColor(hTextColor.Opaque.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

@MainActor private func setUpPreview() -> String {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> MessagesClient in MessagesClientDemo() })
    let store: MessagesStore = globalAppStateContainer.get()
    Task { await store.fetchMessages() }
    return "renewal"
}

#Preview("Email Light") {
    let id = setUpPreview()
    return hNavigationStack(router: NavigationRouter(), tracking: "MessagePreview") {
        MessageDetailScreen(messageId: id)
    }
    .preferredColorScheme(.light)
}

#Preview("Email Dark") {
    let id = setUpPreview()
    return hNavigationStack(router: NavigationRouter(), tracking: "MessagePreview") {
        MessageDetailScreen(messageId: id)
    }
    .preferredColorScheme(.dark)
}

#Preview("SMS") {
    _ = setUpPreview()
    return hNavigationStack(router: NavigationRouter(), tracking: "MessagePreview") {
        MessageDetailScreen(messageId: "sms-payment-reminder")
    }
}
