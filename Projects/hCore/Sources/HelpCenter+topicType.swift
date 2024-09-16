import Foundation

public enum ChatType: Equatable {
    case conversationId(id: String)
    case newConversation
    case inbox
}
