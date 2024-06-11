import Foundation
import hCore

public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func send(message: Message, for conversation: Conversation) async throws -> Message
}
