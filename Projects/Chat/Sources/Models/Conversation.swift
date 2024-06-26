import Foundation
import hGraphQL

public struct Conversation: Identifiable, Equatable, Hashable, Codable {
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }

    public init(
        id: String,
        type: ConversationType,
        title: String,
        subtitle: String?,
        newestMessage: Message?,
        createdAt: String?,
        statusMessage: String?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.newestMessage = newestMessage
        self.createdAt = createdAt
        self.statusMessage = statusMessage
    }

    public let id: String
    let type: ConversationType
    public let title: String
    let subtitle: String?
    let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?

    public init(
        fragment: OctopusGraphQL.ConversationFragment,
        type: ConversationType
    ) {
        self.id = fragment.id
        self.title = fragment.title
        self.subtitle = fragment.title
        if let newestMessage = fragment.newestMessage?.fragments.messageFragment.asMessage() {
            self.newestMessage = .init(newestMessage)
        } else {
            self.newestMessage = nil
        }
        self.createdAt = fragment.createdAt
        self.statusMessage = fragment.statusMessage
        self.type = type
    }
}

public enum ConversationType: Codable, Hashable {
    case legacy
    case service
    case claim
}
