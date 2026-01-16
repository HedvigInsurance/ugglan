import Foundation
import PresentableStore
import hCore

@MainActor
public protocol ChatServiceProtocol {
    func getNewMessages() async throws -> ChatData
    func getPreviousMessages() async throws -> ChatData
    func send(message: Message) async throws -> Message
}

public class ConversationService: ChatServiceProtocol {
    @Inject var client: ConversationClient

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
            conversationId: conversationId,
            hasPreviousMessage: olderToken != nil,
            messages: data.messages,
            banner: data.banner,
            conversationStatus: data.isConversationOpen ?? true ? .open : .closed,
            title: data.screenTitle,
            subtitle: data.subtitle,
            claimId: data.claimId,
            responseIsBeingGenerated: data.responseIsBeingGenerated
        )
    }

    public func getPreviousMessages() async throws -> ChatData {
        log.info("\(ConversationService.self) getConversationMessages", error: nil, attributes: [:])
        let data = try await client.getConversationMessages(
            for: conversationId,
            olderToken: olderToken,
            newerToken: nil
        )
        olderToken = data.olderToken
        return .init(
            conversationId: conversationId,
            hasPreviousMessage: olderToken != nil,
            messages: data.messages,
            banner: data.banner,
            conversationStatus: data.isConversationOpen ?? true ? .open : .closed,
            title: data.screenTitle,
            subtitle: data.subtitle,
            claimId: data.claimId,
            responseIsBeingGenerated: data.responseIsBeingGenerated
        )
    }

    public func send(message: Message) async throws -> Message {
        try await client.send(message: message, for: conversationId)
    }
}

public class NewConversationService: ChatServiceProtocol {
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
            conversationId: "",
            hasPreviousMessage: false,
            messages: [],
            banner: nil,
            conversationStatus: .open,
            title: L10n.chatNewConversationTitle,
            subtitle: L10n.chatNewConversationSubtitle,
            claimId: nil,
            responseIsBeingGenerated: false
        )
    }

    public func getPreviousMessages() async throws -> ChatData {
        log.info("\(NewConversationService.self) getConversationMessages", error: nil, attributes: [:])
        if let conversationService = conversationService {
            return try await conversationService.getPreviousMessages()
        }
        return .init(
            conversationId: "",
            hasPreviousMessage: false,
            messages: [],
            banner: nil,
            conversationStatus: .open,
            title: nil,
            subtitle: nil,
            claimId: nil,
            responseIsBeingGenerated: false
        )
    }

    public func send(message: Message) async throws -> Message {
        log.info("\(NewConversationService.self) send message", error: nil, attributes: [:])

        if conversationService == nil, generatingConversation == false {
            generatingConversation = true
            do {
                let conversation = try await conversationsClient.createConversation(with: id)
                conversationService = .init(conversationId: conversation.id)
            } catch let ex {
                generatingConversation = false
                conversationService = nil
                throw ex
            }
        } else if generatingConversation == true, conversationService == nil {
            throw ConversationsError.errorMesage(message: L10n.chatFailedToSend)
        }
        return try await conversationService!.send(message: message)
    }
}
