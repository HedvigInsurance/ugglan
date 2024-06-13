import Foundation
import hCore

public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func getConversationMessages(for conversationId: String) async throws -> [Message]
    func send(message: Message, for conversationId: String) async throws -> Message
}
