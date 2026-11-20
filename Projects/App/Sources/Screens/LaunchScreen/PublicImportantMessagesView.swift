import AuthenticationCore
import SwiftUI
import hCore
import hCoreUI

/// The important messages on the logged-out first screen, one card per message. When they do not fit the height
/// offered, they scroll inside it.
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
        }
        .sheet(isPresented: $showSafariView) {
            SafariView(url: $urlLink)
        }
    }

    private var cards: some View {
        VStack(spacing: .padding8) {
            ForEach(messages) { message in
                card(message)
            }
        }
        .padding(.vertical, messages.isEmpty ? 0 : .padding8)
    }

    @ViewBuilder
    private func card(_ message: PublicImportantMessage) -> some View {
        if let link = message.link {
            InfoCard(text: message.message, type: message.severity.notificationType)
                .buttons(
                    [
                        .init(
                            buttonTitle: link.text,
                            buttonAction: {
                                urlLink = link.url
                                showSafariView = true
                            }
                        )
                    ]
                )
        } else {
            InfoCard(text: message.message, type: message.severity.notificationType)
        }
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
