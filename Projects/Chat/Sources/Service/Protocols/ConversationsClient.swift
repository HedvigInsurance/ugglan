import Foundation
import hCore

public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ChatData
    func send(message: Message, for conversationId: String) async throws -> Message
}
