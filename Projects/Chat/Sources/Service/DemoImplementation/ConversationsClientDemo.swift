import Foundation

public class ConversationsDemoClient: ConversationsClient, ConversationClient {
    //    private var conversations: [Conversation] = []
    //    private var messages = [String: [Message]]()
    //    private let date = Date()
    public init() {
        //        let newestMessage = Message(
        //            localId: UUID().uuidString,
        //            remoteId: UUID().uuidString,
        //            type: .text(
        //                text:
        //                    "I think someone took my computer"
        //            ),
        //            date: date.addingTimeInterval(-60 * 60 * 3)
        //        )
        //        let conversation = Conversation(
        //            id: "id1",
        //            type: .service,
        //            newestMessage: newestMessage,
        //            createdAt: date.addingTimeInterval((-60 * 60 * 24 * 2)).localDateString,
        //            statusMessage: "",
        //            status: .open,
        //            hasClaim: false,
        //            claimType: nil,
        //            unreadMessageCount: 0
        //        )
        //        conversations.append(conversation)
        //        messages["id1"] = [
        //            newestMessage,
        //            .init(
        //                remoteId: UUID().uuidString,
        //                type: .text(text: "Hi, how may I help you?"),
        //                sender: .hedvig,
        //                date: date.addingTimeInterval(-60 * 60 * 21 * 2)
        //            ),
        //        ]
    }
    public func getConversations() async throws -> [Conversation] {
        //        let conversationsSortedByDate = conversations.sorted(by: {
        //            $0.newestMessage?.sentAt ?? Date() > $1.newestMessage?.sentAt ?? Date()
        //        })
        //        return conversationsSortedByDate
        return []
    }

    public func createConversation(with id: UUID) async throws -> Conversation {
        let conversation = Conversation(
            id: id.uuidString,
            type: .service,
            newestMessage: nil,
            createdAt: nil,
            statusMessage: "status message",
            status: .open,
            hasClaim: false,
            claimType: nil,
            unreadMessageCount: 0
        )
        //        self.conversations.append(conversation)
        return conversation
    }

    public func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData {
        //        let messages = messages[conversationId] ?? []
        return .init(
            messages: [],
            banner: nil,
            olderToken: nil,
            newerToken: nil,
            isConversationOpen: nil,
            createdAt: nil,
            isLegacy: false,
            hasClaim: false,
            claimType: nil,
            claimId: nil
        )
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        //        var messages = self.messages[conversationId] ?? []
        //        messages.append(message)
        //        self.messages[conversationId] = messages
        //        if let conversationIndex = conversations.firstIndex(where: { $0.id == conversationId }) {
        //            let conversation = conversations[conversationIndex]
        //            conversations[conversationIndex] = .init(
        //                id: conversation.id,
        //                type: conversation.type,
        //                newestMessage: message,
        //                createdAt: conversation.createdAt,
        //                statusMessage: conversation.statusMessage,
        //                status: conversation.status,
        //                hasClaim: conversation.hasClaim,
        //                claimType: conversation.claimType,
        //                unreadMessageCount: conversation.unreadMessageCount
        //            )
        //        }
        return message
    }
}
