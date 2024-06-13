import Foundation

public class ConversationsDemoClient: ConversationsClient {
    public func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ChatData {
        let messages = [
            Message(type: .text(text: "text1")),
            Message(type: .text(text: "text2")),
        ]
        return .init(hasNext: false, id: UUID().uuidString, messages: messages, nextUntil: nil, banner: nil)
    }

    public func getConversations() async throws -> [Conversation] {
        return [
            Conversation(
                id: "id1",
                type: .legacy,
                title: "title",
                subtitle: "subtitle",
                newestMessage: nil,
                createdAt: nil
            ),

            Conversation(
                id: "id2",
                type: .service,
                title: "title",
                subtitle: "subtitle",
                newestMessage: .init(
                    localId: "localId2",
                    remoteId: "remoteId2",
                    type: .text(text: "text"),
                    date: Date()
                ),
                createdAt: "2024-06-10"
            ),
        ]
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        return Message(type: .text(text: "send message"))
    }

    public func getConversations(for conversationId: String) async throws -> [Conversation] {
        return []
    }
}
