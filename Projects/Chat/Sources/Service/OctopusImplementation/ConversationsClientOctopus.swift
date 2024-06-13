import Foundation
import hCore
import hGraphQL

public class ConversationsService {
    @Inject var client: ConversationsClient

    func getConversations() async throws -> [Conversation] {
        log.info("\(ConversationsService.self) getConversations", error: nil, attributes: [:])
        return try await client.getConversations()
    }
    func send(message: Message, for conversationId: String) async throws -> Message {
        log.info("\(ConversationsService.self) send message", error: nil, attributes: [:])
        return try await client.send(message: message, for: conversationId)
    }

    func getConversationMessages(for conversationId: String) async throws -> [Message] {
        log.info("\(ConversationsService.self) getConversationMessages", error: nil, attributes: [:])
        return try await client.getConversationMessages(for: conversationId)
    }
}

enum ConversationsError: Error {
    case errorMesage(message: String)
    case missingData
    case uploadFailed
}

extension ConversationsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .errorMesage(message): return message
        case .missingData: return "TODO"
        case .uploadFailed: return "TODO"
        }
    }
}

public class ConversationsClientOctopus: ConversationsClient {
    @Inject var octopus: hOctopus
    var chatFileUploaderService = ChatFileUploaderService()

    public init() {}

    public func getConversations() async throws -> [Conversation] {
        let query = hGraphQL.OctopusGraphQL.ConversationsQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let conversationsFragment = data.currentMember.conversations.compactMap({ $0.fragments.conversationFragment })
        var conversations = conversationsFragment.compactMap({ $0.asConversation(type: .service) })

        if let legacyFragment = data.currentMember.legacyConversation?.fragments.conversationFragment {
            let legacyConversation = legacyFragment.asConversation(type: .legacy)
            conversations.insert(legacyConversation, at: 0)
        }
        return conversations
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        var textToSend: String?
        var fileUplaodTokenToSend: String?
        switch message.type {
        case .text(let text):
            textToSend = text
        case .file(let file):
            do {
                let uploadResponse = try await chatFileUploaderService.upload(files: [file]) { _ in }
                fileUplaodTokenToSend = uploadResponse.first?.uploadToken ?? ""
            } catch let ex {
                throw ConversationsError.uploadFailed
            }
        default:
            break
        }
        let input = OctopusGraphQL.ConversationSendMessageInput(
            id: conversationId,
            text: .init(optionalValue: textToSend),
            fileUploadToken: .init(optionalValue: fileUplaodTokenToSend)
        )
        let mutation = hGraphQL.OctopusGraphQL.ConversationSendMessageMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)
        if let message = data.conversationSendMessage.message?.fragments.messageFragment {
            return message.asMessage()
        } else if let errorMessage = data.conversationSendMessage.userError?.message {
            throw ConversationsError.errorMesage(message: errorMessage)
        }
        throw ConversationsError.missingData
    }

    public func getConversationMessages(for conversationId: String) async throws -> [Message] {
        let query = hGraphQL.OctopusGraphQL.ConversationMessagesQuery(
            conversationId: conversationId,
            olderToken: .none,
            newerToken: .none
        )

        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let messages = data.conversation.messagePage.messages.compactMap({ $0.fragments.messageFragment.asMessage() })
        let newerToken = data.conversation.messagePage.newerToken
        let olderToken = data.conversation.messagePage.olderToken

        return messages
    }
}

extension OctopusGraphQL.ConversationFragment {
    func asConversation(type: ConversationType) -> Conversation {
        return .init(
            id: id,
            type: type,
            title: "TITLE",
            subtitle: "SUBTITLE",
            newestMessage: self.newestMessage?.fragments.messageFragment.asMessage(),
            createdAt: "2024-06-10",
            statusMessage: "STATUS MESSAGE"
        )
    }
}
