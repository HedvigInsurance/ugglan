import Foundation

public enum ChatType: Equatable {
    case conversationId(id: String, claimId: String?)
    case newConversation
    case inbox
}
