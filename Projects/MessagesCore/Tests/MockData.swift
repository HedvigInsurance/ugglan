import Foundation
import hCore

@testable import MessagesCore

typealias FetchMessages = () async throws -> [InboxMessage]
typealias GetMessageContent = (String) async throws -> InboxMessageContent

enum MockMessagesError: Error {
    case fetchMessages
    case getMessageContent
}

@MainActor
struct MockData {
    @discardableResult
    static func createMockMessagesClient(
        fetchMessages: @escaping FetchMessages = { [] },
        getMessageContent: @escaping GetMessageContent = { id in .init(body: "<p>\(id)</p>", preview: nil) }
    ) -> MockMessagesClient {
        let client = MockMessagesClient(fetchMessages: fetchMessages, getMessageContent: getMessageContent)
        Dependencies.shared.add(module: Module { () -> MessagesClient in client })
        return client
    }

    static func message(
        id: String,
        channel: MessageChannel = .email,
        receivedAt: Date = Date(timeIntervalSince1970: 0),
        preview: String? = "preview",
        body: String? = nil
    ) -> InboxMessage {
        .init(
            id: id,
            channel: channel,
            subject: "subject \(id)",
            preview: preview,
            receivedAt: receivedAt,
            sender: "noreply@hedvig.com",
            body: body
        )
    }
}

@MainActor
final class MockMessagesClient: MessagesClient {
    var events = [Event]()
    var fetchMessages: FetchMessages
    var getMessageContent: GetMessageContent

    enum Event: Equatable {
        case getMessages
        case getMessageContent(messageId: String)
    }

    init(fetchMessages: @escaping FetchMessages, getMessageContent: @escaping GetMessageContent) {
        self.fetchMessages = fetchMessages
        self.getMessageContent = getMessageContent
    }

    func getMessages() async throws -> [InboxMessage] {
        events.append(.getMessages)
        return try await fetchMessages()
    }

    func getMessageContent(messageId: String) async throws -> InboxMessageContent {
        events.append(.getMessageContent(messageId: messageId))
        return try await getMessageContent(messageId)
    }
}
