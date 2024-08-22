import Foundation
import StoreContainer
import hCore
import hGraphQL

public class ConversationsClientOctopus: ConversationsClient {
    @Inject private var octopus: hOctopus
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

        let conversationsSortedByDate = conversations.sorted(by: {
            $0.newestMessage?.sentAt ?? $0.createdAt?.localDateToIso8601Date ?? Date() > $1.newestMessage?.sentAt ?? $1
                .createdAt?
                .localDateToIso8601Date ?? Date()
        })
        return conversationsSortedByDate
    }

    public func createConversation(with id: UUID) async throws -> Conversation {
        let input = OctopusGraphQL.ConversationStartInput(id: id.uuidString)
        let mutation = hGraphQL.OctopusGraphQL.ConversationStartMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)
        let conversationsFragment = data.conversationStart.fragments.conversationFragment

        return .init(fragment: conversationsFragment, type: .service)
    }
}
public class ConversationClientOctopus: ConversationClient {
    @Inject var octopus: hOctopus
    var chatFileUploaderService = ChatFileUploaderService()

    public init() {}

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
            } catch _ {
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
            let store: ChatStore = hGlobalPresentableStoreContainer.get()
            store.send(
                .setLastMessageTimestampForConversation(
                    id: conversationId,
                    date: message.sentAt.localDateToIso8601Date ?? Date()
                )
            )
            return message.asMessage()
        } else if let errorMessage = data.conversationSendMessage.userError?.message {
            throw ConversationsError.errorMesage(message: errorMessage)
        }
        throw ConversationsError.missingData

    }

    public func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData {
        let query = hGraphQL.OctopusGraphQL.ConversationMessagesQuery(
            conversationId: conversationId,
            olderToken: .init(optionalValue: olderToken),
            newerToken: .init(optionalValue: newerToken)
        )

        guard
            let conversation = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                .conversation
        else {
            throw ConversationsError.missingConversation
        }
        let messages = conversation.messagePage.messages.compactMap({ $0.fragments.messageFragment.asMessage() })
        let newerToken = conversation.messagePage.newerToken
        let olderToken = conversation.messagePage.olderToken
        let banner = conversation.statusMessage
        let isConversationOpen = conversation.isOpen
        let hasClaim = conversation.claim != nil

        return .init(
            messages: messages,
            banner: banner,
            olderToken: olderToken,
            newerToken: newerToken,
            isConversationOpen: isConversationOpen,
            createdAt: conversation.createdAt,
            isLegacy: conversation.isLegacy,
            hasClaim: hasClaim,
            claimType: conversation.claim?.claimType
        )
    }
}

extension OctopusGraphQL.ConversationFragment {
    func asConversation(type: ConversationType) -> Conversation {
        return .init(
            id: id,
            type: type,
            newestMessage: self.newestMessage?.fragments.messageFragment.asMessage(),
            createdAt: self.createdAt,
            statusMessage: self.statusMessage,
            isConversationOpen: self.isOpen,
            hasClaim: self.claim != nil,
            claimType: self.claim?.claimType
        )
    }
}
