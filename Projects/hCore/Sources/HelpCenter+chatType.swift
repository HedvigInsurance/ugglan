import Foundation

public enum ChatType: Equatable, Sendable {
    case conversationId(id: String)
    case conversationFromClaimWithId(id: String)
    case newConversation
    case inbox
}
