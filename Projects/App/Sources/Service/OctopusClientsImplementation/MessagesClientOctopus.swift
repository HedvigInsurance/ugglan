import Foundation
import MessagesCore
import hCore
import hGraphQL

@MainActor
class MessagesClientOctopus: MessagesClient {
    @Inject var octopus: hOctopus

    func getMessages() async throws -> [InboxMessage] {
        let query = OctopusGraphQL.MessagesInboxQuery()
        let data = try await octopus.client.fetch(query: query)
        return data.currentMember.cioMessages.compactMap { InboxMessage(data: $0) }
    }

    func getMessageContent(messageId: String) async throws -> InboxMessageContent {
        let query = OctopusGraphQL.MessageContentQuery(messageId: messageId)
        let data = try await octopus.client.fetch(query: query)
        guard let content = data.currentMember.cioMessageContent else {
            throw MessagesError.missingBody
        }
        return .init(body: content.content, preview: content.preheader)
    }
}

extension InboxMessage {
    /// Nil for deliveries the inbox can't show: an unknown channel or an unreadable timestamp.
    fileprivate init?(data: OctopusGraphQL.MessagesInboxQuery.Data.CurrentMember.CioMessage) {
        guard let channel = data.messageType.flatMap({ MessageChannel(type: $0.value) }),
            let receivedAt = Self.parseTimestamp(data.timestamp)
        else { return nil }
        self.init(
            id: data.externalMessageId,
            channel: channel,
            subject: data.subject,
            preview: data.preheader,
            receivedAt: receivedAt,
            sender: data.sender,
            body: nil
        )
    }

    /// The backend sends an ISO-8601 instant, with or without fractional seconds.
    private static func parseTimestamp(_ timestamp: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: timestamp)
    }
}

extension MessageChannel {
    fileprivate init?(type: OctopusGraphQL.CioMessageType?) {
        switch type {
        case .email: self = .email
        case .sms: self = .sms
        case .kivra: self = .kivra
        case nil: return nil
        }
    }
}
