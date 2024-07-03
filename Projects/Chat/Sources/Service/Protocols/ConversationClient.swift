import Foundation
import hCore
import hCoreUI

public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func createConversation(with id: UUID) async throws -> Conversation
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
    let olderToken: String?
    let newerToken: String?
    let isConversationOpen: Bool?
    let title: String?
    let createdAt: String?
    let isLegacy: Bool

    var subtitle: String? {
        if isLegacy { return nil }
        guard let date = createdAt?.localDateToIso8601Date?.displayDateDDMMMYYYYFormat else {
            return nil
        }
        return "\(L10n.ClaimStatusDetail.submitted) \(date)"
    }
}
