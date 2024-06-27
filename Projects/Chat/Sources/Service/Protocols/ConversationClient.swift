import Foundation
import hCore

public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func createConversation() async throws -> Conversation
}

public protocol ConversationClient {
    func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData
    func send(message: Message, for conversationId: String) async throws -> Message
}

public struct ConversationMessagesData {
    let messages: [Message]
    let banner: Markdown?
    let isConversationOpen: Bool?
    let olderToken: String?
    let newerToken: String?
}
