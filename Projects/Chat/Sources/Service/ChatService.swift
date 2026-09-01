import AutomaticLog
import Foundation
import hCore

@MainActor
public protocol ChatServiceProtocol {
    func getNewMessages() async throws -> ChatData
    func getPreviousMessages() async throws -> ChatData
    func send(message: Message) async throws -> Message
    func hideCrossSales() async throws
}

public class ConversationService: ChatServiceProtocol {
    @Inject var client: ConversationClient

    private let conversationId: String
    private var olderToken: String?
    private var newerToken: String?

    public init(conversationId: String) {
        self.conversationId = conversationId
    }

    @Log
    public func getNewMessages() async throws -> ChatData {
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
            responseIsBeingGenerated: data.responseIsBeingGenerated,
            showCrossSales: data.showCrossSales
        )
    }

    @Log
    public func getPreviousMessages() async throws -> ChatData {
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
            responseIsBeingGenerated: data.responseIsBeingGenerated,
            showCrossSales: data.showCrossSales
        )
    }

    public func send(message: Message) async throws -> Message {
        try await client.send(message: message, for: conversationId)
    }

    @Log
    public func hideCrossSales() async throws {
        try await client.hideCrossSales(for: conversationId)
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

    @Log
    public func getNewMessages() async throws -> ChatData {
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
            responseIsBeingGenerated: false,
            showCrossSales: false
        )
    }

    @Log
    public func getPreviousMessages() async throws -> ChatData {
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
            responseIsBeingGenerated: false,
            showCrossSales: false
        )
    }

    @Log(sensitive: ["message"])
    public func send(message: Message) async throws -> Message {
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

    @Log
    public func hideCrossSales() async throws {
        // Nothing exists server-side until the member sends their first message, and the
        // gate is false until then, so there is never anything to hide at this point.
        try await conversationService?.hideCrossSales()
    }
}
