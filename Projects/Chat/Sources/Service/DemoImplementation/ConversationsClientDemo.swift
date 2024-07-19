import Foundation

public class ConversationsDemoClient: ConversationsClient {

    public init() {}
    public func getConversations() async throws -> [Conversation] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let conversations = [
            Conversation(
                id: "id1",
                type: .legacy,
                title: "Lorem ipsum dolor sit amet title",
                subtitle: "subtitle",
                newestMessage: .init(
                    localId: "",
                    remoteId: "",
                    type: .text(
                        text:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                    ),
                    date: Date()
                ),
                createdAt: "2024-06-20",
                statusMessage: "status message",
                isConversationOpen: false
            ),

            Conversation(
                id: "id2",
                type: .service,
                title:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                subtitle:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
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
                title: "Claim: very very very very very long title",
                subtitle: "Chronical gastrointestinal issues",
                newestMessage: .init(
                    localId: "localId2",
                    remoteId: "remoteId2",
                    type: .text(
                        text:
                            "Lorem ipsum dolor sit amet consectetur. Accumsan vitae adipiscing blandit id et interdum."
                    ),
                    date: Date().addingTimeInterval(-60)
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
                    date: Date().addingTimeInterval(-60 * 60 * 24)
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
            title: nil,
            createdAt: nil,
            isLegacy: false
        )
    }

    public func send(message: Message, for conversationId: String) async throws -> Message {
        return Message(type: .text(text: "send message"))
    }
}
