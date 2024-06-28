import Foundation

public class ConversationsDemoClient: ConversationsClient {

    public init() {}
    public func getConversations() async throws -> [Conversation] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let someDateTime = formatter.date(from: "2024-06-08 22:31")
        let dateYesterday = formatter.date(from: "2024-06-27 22:31")

        let conversations = [
            Conversation(
                id: "id1",
                type: .legacy,
                title: "title",
                subtitle: "subtitle",
                newestMessage: .init(
                    localId: "",
                    remoteId: "",
                    type: .text(text: "hello hello"),
                    date: someDateTime ?? Date()
                ),
                createdAt: "2024-05-06",
                statusMessage: "status message",
                isConversationOpen: false
            ),

            Conversation(
                id: "id2",
                type: .service,
                title: "Claim",
                subtitle: "Broken phone",
                newestMessage: .init(
                    localId: "localId2",
                    remoteId: "remoteId2",
                    type: .text(text: "Please tell us more what happened when the phone broke."),
                    date: Date()
                ),
                createdAt: "2024-06-10",
                statusMessage: "status message",
                isConversationOpen: true
            ),

            Conversation(
                id: "id3",
                type: .claim,
                title: "Claim",
                subtitle: "Chronical gastrointestinal issues",
                newestMessage: .init(
                    localId: "localId2",
                    remoteId: "remoteId2",
                    type: .text(
                        text:
                            "Lorem ipsum dolor sit amet consectetur. Accumsan vitae adipiscing blandit id et interdum."
                    ),
                    date: Date()
                ),
                createdAt: "2024-06-10",
                statusMessage: "status message",
                isConversationOpen: true
            ),

            Conversation(
                id: "id4",
                type: .claim,
                title: "Claim",
                subtitle: "Chronical gastrointestinal issues",
                newestMessage: .init(
                    localId: "localId2",
                    remoteId: "remoteId2",
                    type: .text(
                        text:
                            "Lorem ipsum dolor sit amet consectetur. Accumsan vitae adipiscing blandit id et interdum."
                    ),
                    date: dateYesterday ?? Date()
                ),
                createdAt: "2024-06-19",
                statusMessage: "status message",
                isConversationOpen: true
            ),
        ]

        let conversationsSortedByDate = conversations.sorted(by: {
            $0.newestMessage?.sentAt ?? Date() > $1.newestMessage?.sentAt ?? Date()
        })
        return conversationsSortedByDate
    }

    public func createConversation(with id: UUID) async throws -> Conversation {
        return Conversation(
            id: id.uuidString,
            type: .legacy,
            title: "title",
            subtitle: "subtitle",
            newestMessage: nil,
            createdAt: nil,
            statusMessage: "status message",
            isConversationOpen: true
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
        return .init(
            messages: messages,
            banner: nil,
            olderToken: nil,
            newerToken: nil,
            isConversationOpen: nil,
            title: nil
        )
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        return Message(type: .text(text: "send message"))
    }
}
