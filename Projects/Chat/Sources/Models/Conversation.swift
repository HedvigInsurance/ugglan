import Foundation

public struct Conversation: Identifiable, Equatable {
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }

    public let id: String
    let type: ConversationType
    let title: String
    let subtitle: String?
    let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?
}

public enum ConversationType {
    case legacy
    case service
    case claim
}
