import Foundation

@MainActor
public class MessagesClientDemo: MessagesClient {
    private let messages: [InboxMessage]
    private let delay: Duration

    public init(messages: [InboxMessage] = MessagesClientDemo.sampleMessages(), delay: Duration = .zero) {
        self.messages = messages
        self.delay = delay
    }

    public func getMessages() async throws -> [InboxMessage] {
        try await Task.sleep(for: delay)
        return messages
    }

    public func getMessageContent(messageId: String) async throws -> InboxMessageContent {
        try await Task.sleep(for: delay)
        guard let message = messages.first(where: { $0.id == messageId }), let body = message.body else {
            throw MessagesError.missingBody
        }
        return .init(body: body, preview: message.preview)
    }
}

extension MessagesClientDemo {
    /// The messages shown in the Figma frames. Dates are relative to `now` so "Yesterday" stays correct.
    public nonisolated static func sampleMessages(now: Date = Date()) -> [InboxMessage] {
        let calendar = Calendar.current
        func daysAgo(_ days: Int, hour: Int = 9, minute: Int = 14) -> Date {
            let day = calendar.date(byAdding: .day, value: -days, to: now) ?? now
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        return [
            .init(
                id: "renewal",
                channel: .email,
                subject: "Your insurance renews on 1 December",
                preview: "Here is a summary of your renewed policy and what it costs from December.",
                receivedAt: now.addingTimeInterval(-60 * 60),
                sender: "noreply@hedvig.com",
                body: renewalHtml
            ),
            .init(
                id: "claim-approved",
                channel: .email,
                subject: "Your claim has been approved",
                preview: "We have reviewed your claim and the payout is on its way to your account.",
                receivedAt: daysAgo(1),
                sender: "noreply@hedvig.com",
                body: """
                    <h1>Hedvig</h1>
                    <p>Hi there,</p>
                    <p>We have reviewed your claim and the payout is on its way to your account.</p>
                    <a href="https://hedvig.com">See your claim</a>
                    """
            ),
            .init(
                id: "sms-payment-reminder",
                channel: .sms,
                subject: "Payment reminder",
                preview: "Your payment for December will be charged on the 27th.",
                receivedAt: daysAgo(4),
                sender: "Hedvig",
                body: "Hi! Your payment for December will be charged on the 27th. /Hedvig"
            ),
            .init(
                id: "terms-update",
                channel: .email,
                subject: "Updates to your insurance terms",
                preview: "Some changes apply now, others from 1 January 2027.",
                receivedAt: daysAgo(15),
                sender: "noreply@hedvig.com",
                body: """
                    <h1>Hedvig</h1>
                    <p>Hi there,</p>
                    <p>Some changes to your terms apply now, others from 1 January 2027.</p>
                    <a href="https://hedvig.com">Read your full terms</a>
                    """
            ),
            .init(
                id: "kivra-invoice",
                channel: .kivra,
                subject: "Your invoice for November",
                preview: "Your invoice is now available in Kivra.",
                receivedAt: daysAgo(18),
                sender: "Kivra",
                body: "Your invoice for November is now available. It will be paid automatically on the due date."
            ),
            .init(
                id: "payment-confirmed",
                channel: .email,
                subject: "Your November payment is confirmed",
                preview: "Thanks! We have received your payment for November.",
                receivedAt: daysAgo(21),
                sender: "noreply@hedvig.com",
                body: """
                    <h1>Hedvig</h1>
                    <p>Thanks! We have received your payment for November.</p>
                    """
            ),
        ]
    }

    private nonisolated static let renewalHtml = """
        <h1>Hedvig</h1>
        <p>Hi there,</p>
        <p>Your home insurance renews on 1 December. Nothing changes in your cover. \
        Your new monthly price is [PRICE].</p>
        <p><a href="https://hedvig.com/terms">Read your full terms</a></p>
        <a class="button" href="https://hedvig.com/policy">See your policy</a>
        """
}
