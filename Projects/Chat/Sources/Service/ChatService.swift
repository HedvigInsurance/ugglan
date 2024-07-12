import Foundation
import hCore
import hCoreUI
import hGraphQL

public protocol ChatServiceProtocol {
    var type: ChatServiceType { get }
    func getNewMessages() async throws -> ChatData
    func getPreviousMessages() async throws -> ChatData
    func send(message: Message) async throws -> Message
}

public class ConversationService: ChatServiceProtocol {
    public var type: ChatServiceType = .conversation
    @Inject var client: ConversationClient
    @PresentableStore var store: ChatStore

    private let conversationId: String
    private var olderToken: String?
    private var newerToken: String?

    public init(conversationId: String) {
        self.conversationId = conversationId
    }

    public func getNewMessages() async throws -> ChatData {
        log.info("\(ConversationService.self) getConversationMessages", error: nil, attributes: [:])
        let data = try await client.getConversationMessages(
            for: conversationId,
            olderToken: nil,
            newerToken: newerToken
        )
        if olderToken == nil {
            olderToken = data.olderToken
        }
        newerToken = data.newerToken
        if let sendAt = data.messages.first?.sentAt {
            store.send(.setLastMessageTimestampForConversation(id: conversationId, date: sendAt))
        }
        return .init(
            hasPreviousMessage: olderToken != nil,
            messages: data.messages,
            banner: data.banner,
            isConversationOpen: data.isConversationOpen ?? true,
            title: data.screenTitle,
            subtitle: data.subtitle
        )
    }

    public func getPreviousMessages() async throws -> ChatData {
        log.info("\(ConversationService.self) getConversationMessages", error: nil, attributes: [:])
        let data = try await client.getConversationMessages(
            for: conversationId,
            olderToken: olderToken,
            newerToken: nil
        )
        self.olderToken = data.olderToken
        return .init(
            hasPreviousMessage: olderToken != nil,
            messages: data.messages,
            banner: data.banner,
            isConversationOpen: data.isConversationOpen ?? true,
            title: data.screenTitle,
            subtitle: data.subtitle
        )

    }

    public func send(message: Message) async throws -> Message {
        return try await client.send(message: message, for: conversationId)
    }
}

public class NewConversationService: ChatServiceProtocol {
    public var type: ChatServiceType = .conversation
    @Inject var conversationsClient: ConversationsClient
    private var conversationService: ConversationService?
    private var generatingConversation = false
    private let id: UUID
    public init(with id: UUID = UUID()) {
        self.id = id
    }

    public func getNewMessages() async throws -> ChatData {
        log.info("\(NewConversationService.self) getConversationMessages", error: nil, attributes: [:])
        if let conversationService = conversationService {
            return try await conversationService.getNewMessages()
        }
        return .init(
            hasPreviousMessage: false,
            messages: [],
            banner: nil,
            isConversationOpen: true,
            title: L10n.chatNewConversationTitle,
            subtitle: L10n.chatNewConversationSubtitle
        )
    }

    public func getPreviousMessages() async throws -> ChatData {
        log.info("\(NewConversationService.self) getConversationMessages", error: nil, attributes: [:])
        if let conversationService = conversationService {
            return try await conversationService.getPreviousMessages()
        }
        return .init(
            hasPreviousMessage: false,
            messages: [],
            banner: nil,
            isConversationOpen: true,
            title: nil,
            subtitle: nil
        )
    }

    public func send(message: Message) async throws -> Message {
        log.info("\(NewConversationService.self) send message", error: nil, attributes: [:])

        if conversationService == nil && generatingConversation == false {
            generatingConversation = true
            do {
                let conversation = try await conversationsClient.createConversation(with: id)
                conversationService = .init(conversationId: conversation.id)
            } catch let ex {
                generatingConversation = false
                conversationService = nil
                throw ex
            }
        } else if generatingConversation == true && conversationService == nil {
            throw ConversationsError.errorMesage(message: L10n.chatFailedToSend)
        }
        return try await conversationService!.send(message: message)
    }
}

public class MessagesService: ChatServiceProtocol {
    public var type: ChatServiceType = .oldChat
    @Inject var client: FetchMessagesClient
    @Inject var service: SendMessageClient
    @PresentableStore var store: ChatStore

    private var previousTimeStamp: String?
    let topic: ChatTopicType?

    public init(topic: ChatTopicType?) {
        self.topic = topic
    }

    public func getNewMessages() async throws -> ChatData {
        let data = try await get(nil)
        if previousTimeStamp == nil {
            previousTimeStamp = data.olderToken
        }

        if let sendAt = data.messages.first?.sentAt {
            store.send(.setLastMessageDate(date: sendAt))
        }
        return .init(
            hasPreviousMessage: data.hasNext,
            messages: data.messages,
            banner: data.banner,
            isConversationOpen: nil,
            title: data.title,
            subtitle: nil
        )
    }

    public func getPreviousMessages() async throws -> ChatData {
        let data = try await get(previousTimeStamp)
        previousTimeStamp = data.olderToken
        return .init(
            hasPreviousMessage: data.hasNext,
            messages: data.messages,
            banner: data.banner,
            isConversationOpen: nil,
            title: data.title,
            subtitle: nil
        )
    }

    public func send(message: Message) async throws -> Message {
        return try await send(message: message, topic: topic)
    }

    public func get(_ next: String?) async throws -> MessagesData {
        log.info("FetchMessagesService: get", error: nil, attributes: nil)
        return try await client.get(next)
    }

    public func send(message: Message, topic: ChatTopicType?) async throws -> Message {
        log.info("SendMessagesService: send", error: nil, attributes: nil)
        return try await service.send(message: message, topic: topic)
    }
}
