import Foundation
import hCore

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
                responseIsBeingGenerated: false,
                showCrossSales: false
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
                responseIsBeingGenerated: false,
                showCrossSales: false
            )
        },
        sendMessage: @escaping SendMessage = { _ in .init(type: .text(text: "test", action: nil)) },
        hideCrossSales: @escaping HideCrossSales = {}
    ) -> MockConversationService {
        let service = MockConversationService(
            fetchNewMessages: fetchNewMessages,
            fetchPreviousMessages: fetchPreviousMessages,
            sendMessage: sendMessage,
            hideCrossSales: hideCrossSales
        )
        return service
    }

    @discardableResult
    static func createMockConversationClient(showCrossSales: Bool = false) -> MockConversationClient {
        let client = MockConversationClient(showCrossSales: showCrossSales)
        Dependencies.shared.add(module: Module { () -> ConversationClient in client })
        return client
    }
}

@MainActor
class MockConversationClient: ConversationClient {
    var hiddenCrossSalesIds = [String]()
    private let showCrossSales: Bool

    init(showCrossSales: Bool) {
        self.showCrossSales = showCrossSales
    }

    func getConversationMessages(
        for _: String,
        olderToken _: String?,
        newerToken _: String?
    ) async throws -> ConversationMessagesData {
        .init(
            messages: [],
            banner: nil,
            olderToken: nil,
            newerToken: nil,
            isConversationOpen: true,
            createdAt: nil,
            isLegacy: false,
            hasClaim: false,
            claimType: nil,
            claimId: nil,
            responseIsBeingGenerated: false,
            showCrossSales: showCrossSales
        )
    }

    func send(message: Message, for _: String) async throws -> Message {
        message
    }

    func hideCrossSales(for conversationId: String) async throws {
        hiddenCrossSalesIds.append(conversationId)
    }
}

typealias FetchNewMessages = () async throws -> ChatData
typealias FetchPreviousMessages = () async throws -> ChatData
typealias SendMessage = (Message) async throws -> Message
typealias HideCrossSales = () async throws -> Void

enum ChatError: Error {
    case fetchMessagesFailed
    case fetchPreviousMessagesFailed
    case sendMessageFailed
    case hideCrossSalesFailed
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
        claimId: String? = nil,
        showCrossSales: Bool = false
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
            responseIsBeingGenerated: false,
            showCrossSales: showCrossSales
        )
    }
}

class MockConversationService: ChatServiceProtocol {
    var events = [Event]()
    var fetchNewMessages: FetchNewMessages
    var fetchPreviousMessages: FetchPreviousMessages
    var sendMessage: SendMessage
    var hideCrossSalesClosure: HideCrossSales
    enum Event {
        case getNewMessages
        case getPreviousMessages
        case sendMessage
        case hideCrossSales
    }

    init(
        fetchNewMessages: @escaping FetchNewMessages,
        fetchPreviousMessages: @escaping FetchPreviousMessages,
        sendMessage: @escaping SendMessage,
        hideCrossSales: @escaping HideCrossSales
    ) {
        self.fetchNewMessages = fetchNewMessages
        self.fetchPreviousMessages = fetchPreviousMessages
        self.sendMessage = sendMessage
        hideCrossSalesClosure = hideCrossSales
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

    func hideCrossSales() async throws {
        events.append(.hideCrossSales)
        try await hideCrossSalesClosure()
    }
}
