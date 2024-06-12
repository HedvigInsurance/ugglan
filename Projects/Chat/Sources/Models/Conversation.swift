import Foundation

public struct Conversation: Identifiable {
    public let id: String
    let type: ConversationType
    let title: String
    let subtitle: String?
    let newestMessage: Message?
    let createdAt: String?
}

public enum ConversationType {
    case legacy
    case service
    case claim
}
