import Foundation

public class ConversationsDemoClient: ConversationsClient {

    public init() {}
    public func getConversations() async throws -> [Conversation] {
        return [
            Conversation(
                id: "id1",
                type: .legacy,
                title: "title",
                subtitle: "subtitle",
                newestMessage: nil,
                createdAt: nil,
                statusMessage: "status message"
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
                createdAt: "2024-06-10",
                statusMessage: "status message"
            ),
        ]
    }

    public func createConversation() async throws -> Conversation {
        return Conversation(
            id: "id1",
            type: .legacy,
            title: "title",
            subtitle: "subtitle",
            newestMessage: nil,
            createdAt: nil,
            statusMessage: "status message"
        )
    }
}

public class ConversationDemoClient: ConversationClient {

    public init() {}

    public func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData {
        let messages = [
            Message(type: .text(text: "text1")),
            Message(type: .text(text: "text2")),
        ]
        return .init(messages: messages, banner: nil, olderToken: nil, newerToken: nil)
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        return Message(type: .text(text: "send message"))
    }
}
