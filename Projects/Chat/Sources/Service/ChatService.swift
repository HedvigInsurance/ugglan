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
