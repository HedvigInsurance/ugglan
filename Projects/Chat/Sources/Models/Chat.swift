import Foundation
import hCore

public struct ChatData {
    let hasPreviousMessage: Bool
    let messages: [Message]
    let banner: Markdown?
    let conversationStatus: ConversationStatus?
    let title: String?
    let subtitle: String?
}
