import Foundation

public struct Conversation {
    let id: String
    let type: ConversationType
    let title: String
    let subtitle: String?
    let newestMessage: Message?
}

public enum ConversationType {
    case legacy
    case service
    case claim
}
