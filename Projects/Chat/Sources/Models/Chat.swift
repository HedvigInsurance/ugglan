import Foundation
import hCore

public struct ChatData {
    let hasPreviousMessage: Bool
    let messages: [Message]
    let banner: Markdown?
    let isConversationOpen: Bool?
    let title: String?
    let createdAt: String?
}
