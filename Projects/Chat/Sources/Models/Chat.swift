import Foundation
import hCore

public struct ChatData: Sendable {
    let conversationId: String
    let hasPreviousMessage: Bool
    let messages: [Message]
    let banner: Markdown?
    let conversationStatus: ConversationStatus?
    let title: String?
    let subtitle: String?
    let claimId: String?
    let responseIsBeingGenerated: Bool
}
