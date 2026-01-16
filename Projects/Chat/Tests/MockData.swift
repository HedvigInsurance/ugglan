import Foundation

@testable import Chat

@MainActor
struct MockData {
    static func createMockChatService(
        fetchNewMessages: @escaping FetchNewMessages = {
            .init(
                conversationId: "",
                hasPreviousMessage: false,
                messages: [],
                banner: nil,
                conversationStatus: nil,
                title: nil,
                subtitle: nil,
                claimId: nil,
                responseIsBeingGenerated: false
            )
        },
        fetchPreviousMessages: @escaping FetchPreviousMessages = {
            .init(
                conversationId: "",
                hasPreviousMessage: false,
                messages: [],
                banner: nil,
                conversationStatus: nil,
                title: nil,
                subtitle: nil,
                claimId: nil,
                responseIsBeingGenerated: false
            )
        },
        sendMessage: @escaping SendMessage = { _ in .init(type: .text(text: "test", action: nil)) }
    ) -> MockConversationService {
        let service = MockConversationService(
            fetchNewMessages: fetchNewMessages,
            fetchPreviousMessages: fetchPreviousMessages,
            sendMessage: sendMessage
        )
        return service
    }
}

typealias FetchNewMessages = () async throws -> ChatData
typealias FetchPreviousMessages = () async throws -> ChatData
typealias SendMessage = (Message) async throws -> Message

enum ChatError: Error {
    case fetchMessagesFailed
    case fetchPreviousMessagesFailed
    case sendMessageFailed
}

extension ChatData {
    init(
        conversationId: String = "",
        with messages: [Message] = [],
        hasPreviousMessages: Bool = false,
        banner: String? = nil,
        conversationStatus: ConversationStatus? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        claimId: String? = nil
    ) {
        self.init(
            conversationId: conversationId,
            hasPreviousMessage: hasPreviousMessages,
            messages: messages,
            banner: banner,
            conversationStatus: conversationStatus,
            title: title,
            subtitle: subtitle,
            claimId: claimId,
            responseIsBeingGenerated: false
        )
    }
}

class MockConversationService: ChatServiceProtocol {
    var events = [Event]()
    var fetchNewMessages: FetchNewMessages
    var fetchPreviousMessages: FetchPreviousMessages
    var sendMessage: SendMessage
    enum Event {
        case getNewMessages
        case getPreviousMessages
        case sendMessage
    }

    init(
        fetchNewMessages: @escaping FetchNewMessages,
        fetchPreviousMessages: @escaping FetchPreviousMessages,
        sendMessage: @escaping SendMessage

    ) {
        self.fetchNewMessages = fetchNewMessages
        self.fetchPreviousMessages = fetchPreviousMessages
        self.sendMessage = sendMessage
    }

    func getNewMessages() async throws -> ChatData {
        events.append(.getNewMessages)
        let chatData = try await fetchNewMessages()
        return chatData
    }

    func getPreviousMessages() async throws -> ChatData {
        events.append(.getPreviousMessages)
        let chatData = try await fetchPreviousMessages()
        return chatData
    }

    func send(message: Message) async throws -> Message {
        events.append(.sendMessage)
        let newMessage = Message(id: message.id, type: message.type, date: message.sentAt)
        return try await sendMessage(newMessage)
    }
}
