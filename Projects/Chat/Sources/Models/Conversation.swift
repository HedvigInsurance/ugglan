import Foundation
import Presentation
import hGraphQL

public struct Conversation: Identifiable, Hashable, Codable {
    public init(
        id: String,
        type: ConversationType,
        title: String,
        subtitle: String?,
        newestMessage: Message?,
        createdAt: String?,
        statusMessage: String?,
        isConversationOpen: Bool?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.newestMessage = newestMessage
        self.createdAt = createdAt
        self.statusMessage = statusMessage
        self.isConversationOpen = isConversationOpen
    }

    public let id: String
    let type: ConversationType
    public let title: String
    let subtitle: String?
    public let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?
    let isConversationOpen: Bool?

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
        self.isConversationOpen = fragment.isOpen
    }
}

public enum ConversationType: Codable, Hashable {
    case legacy
    case service
    case claim
}
