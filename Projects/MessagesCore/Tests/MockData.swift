import Foundation
import hCore

@testable import MessagesCore

typealias FetchMessages = () async throws -> [InboxMessage]
typealias MarkAsRead = (String) async throws -> Void

enum MockMessagesError: Error {
    case fetchMessages
    case markAsRead
}

@MainActor
struct MockData {
    @discardableResult
    static func createMockMessagesClient(
        fetchMessages: @escaping FetchMessages = { [] },
        markAsRead: @escaping MarkAsRead = { _ in }
    ) -> MockMessagesClient {
        let client = MockMessagesClient(fetchMessages: fetchMessages, markAsRead: markAsRead)
        Dependencies.shared.add(module: Module { () -> MessagesClient in client })
        return client
    }

    static func message(
        id: String,
        channel: MessageChannel = .email,
        receivedAt: Date = Date(timeIntervalSince1970: 0),
        isRead: Bool = false
    ) -> InboxMessage {
        .init(
            id: id,
            channel: channel,
            category: "category",
            subject: "subject \(id)",
            preview: "preview \(id)",
            receivedAt: receivedAt,
            isRead: isRead,
            sender: "Hedvig",
            senderAddress: "noreply@hedvig.com",
            htmlBody: channel == .email ? "<p>\(id)</p>" : nil,
            textBody: channel == .email ? nil : id
        )
    }
}

@MainActor
final class MockMessagesClient: MessagesClient {
    var events = [Event]()
    var fetchMessages: FetchMessages
    var markAsRead: MarkAsRead

    enum Event: Equatable {
        case getMessages
        case markAsRead(messageId: String)
    }

    init(fetchMessages: @escaping FetchMessages, markAsRead: @escaping MarkAsRead) {
        self.fetchMessages = fetchMessages
        self.markAsRead = markAsRead
    }

    func getMessages() async throws -> [InboxMessage] {
        events.append(.getMessages)
        return try await fetchMessages()
    }

    func markAsRead(messageId: String) async throws {
        events.append(.markAsRead(messageId: messageId))
        try await markAsRead(messageId)
    }
}
