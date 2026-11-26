import AuthenticationCore
import SwiftUI
import hCore
import hCoreUI

struct PublicImportantMessagesView: View {
    let messages: [PublicImportantMessage]
    @State private var showSafariView = false
    @State private var urlLink: URL?

    var body: some View {
        ViewThatFits(in: .vertical) {
            cards
            ScrollView {
                cards
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.visible)
            .scrollIndicatorsFlash(onAppear: true)
        }
        .animation(.easeInOut, value: messages)
        .sheet(isPresented: $showSafariView) {
            SafariView(url: $urlLink)
        }
    }

    private var cards: some View {
        VStack(spacing: .padding8) {
            ForEach(messages) { message in
                card(message)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, messages.isEmpty ? 0 : .padding8)
    }

    @ViewBuilder
    private func card(_ message: PublicImportantMessage) -> some View {
        let label = message.severity.accessibilityPrefix + "\n" + message.message
        if let link = message.link {
            InfoCard(text: message.message, type: message.severity.notificationType)
                .buttons([.init(buttonTitle: link.text, buttonAction: { open(link) })])
                .accessibilityElement(children: .combine)
                .accessibilityLabel(label)
                .accessibilityHint(link.text)
                .accessibilityAddTraits(.isLink)
                .accessibilityAction { open(link) }
        } else {
            InfoCard(text: message.message, type: message.severity.notificationType)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(label)
        }
    }

    private func open(_ link: PublicImportantMessage.Link) {
        urlLink = link.url
        showSafariView = true
    }
}

extension PublicImportantMessage.Severity {
    fileprivate var notificationType: NotificationType {
        switch self {
        case .info: .info
        case .warning: .attention
        case .error: .error
        }
    }

    /// VoiceOver does not see the card's colour or icon.
    fileprivate var accessibilityPrefix: String {
        switch self {
        case .error: L10n.generalError
        case .warning, .info: L10n.voiceoverNotificationAlert
        }
    }
}

#Preview("Each severity") {
    PublicImportantMessagesView(messages: [
        .init(
            id: "error",
            message: "Logging in is not working right now. We are on it.",
            severity: .error,
            link: .init(url: URL(string: "https://www.hedvig.com")!, text: "Status")
        ),
        .init(
            id: "warning",
            message: "Logging in with BankID is slower than usual right now.",
            severity: .warning,
            link: nil
        ),
        .init(
            id: "info",
            message: "Our phone lines are closed today. Chat with us in the app.",
            severity: .info,
            link: .init(url: URL(string: "https://www.hedvig.com")!, text: "Read more")
        ),
    ])
    .padding()
}

#Preview("No messages") {
    PublicImportantMessagesView(messages: [])
        .padding()
}
