import Foundation
import hCore

public protocol ConversationClient {
    func getConversations() async throws -> [Conversation]
    func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData
    func send(message: Message, for conversationId: String) async throws -> Message
    func createConversation() async throws -> Conversation
}

public struct ConversationMessagesData {
    let messages: [Message]
    let banner: Markdown?
    let olderToken: String?
    let newerToken: String?
}
