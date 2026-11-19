import AppStateContainer
import MessagesCore
import SwiftUI
import hCore
import hCoreUI

struct MessageDetailScreen: View {
    let messageId: String
    @AppObservedObject private var store: MessagesStore
    @State private var bodyLoadFailed = false

    var body: some View {
        if let message = store.message(with: messageId) {
            MessageDetailContent(message: message, bodyLoadFailed: bodyLoadFailed) {
                Task { await loadBody() }
            }
            .task { await loadBody() }
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

    private func loadBody() async {
        bodyLoadFailed = false
        do {
            try await store.loadBody(messageId: messageId)
        } catch {
            bodyLoadFailed = true
        }
    }
}

private struct MessageDetailContent: View {
    let message: InboxMessage
    let bodyLoadFailed: Bool
    let onRetry: () -> Void

    var body: some View {
        MessagesScreenLayout(title: message.channel.title) {
            VStack(alignment: .leading, spacing: .padding24) {
                if message.subject != nil || message.preview != nil {
                    VStack(alignment: .leading, spacing: .padding8) {
                        if let subject = message.subject {
                            hText(subject, style: .heading2)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .accessibilityAddTraits(.isHeader)
                        }
                        if let preview = message.preview {
                            hText(preview, style: .body1)
                                .foregroundColor(hTextColor.Translucent.secondary)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, .padding16)
                    // The preheader can arrive with the body, after the screen is shown.
                    .messagesAnimation(value: message.preview)
                }
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
                        .messagesAnimation(value: BodyPhase(message: message, failed: bodyLoadFailed))
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
                if let sender = message.sender {
                    hText(sender, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                hText(message.receivedAtLabel, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        // Spelled out so VoiceOver never reads a truncated address.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([message.sender, message.receivedAtLabel].compactMap { $0 }.joined(separator: ", "))
    }

    @ViewBuilder
    private var messageBody: some View {
        if let body = message.body {
            Group {
                if message.channel == .email {
                    EmailWebView(html: body)
                } else {
                    hText(body, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .transition(.opacity)
        } else if bodyLoadFailed {
            GenericErrorView(formPosition: nil)
                .hStateViewButtonConfig(.init(actionButton: .init(buttonAction: onRetry)))
                .transition(.opacity)
        } else {
            DotsActivityIndicator(.standard)
                .frame(maxWidth: .infinity)
                .accessibilityElement()
                .accessibilityLabel(L10n.embarkLoading)
                .transition(.opacity)
        }
    }
}

/// Which of loader, error and body the message card shows; drives its cross-fade.
private enum BodyPhase: Equatable {
    case loading
    case failed
    case loaded

    init(message: InboxMessage, failed: Bool) {
        self = message.body != nil ? .loaded : failed ? .failed : .loading
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
