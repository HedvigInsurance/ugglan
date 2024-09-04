import Foundation
import Presentation
import hCore
import hGraphQL

public struct Conversation: Identifiable, Hashable, Codable {
    public init(
        id: String,
        type: ConversationType,
        newestMessage: Message?,
        createdAt: String?,
        statusMessage: String?,
        isConversationOpen: Bool?,
        hasClaim: Bool,
        claimType: String?,
        unreadMessageCount: Int
    ) {
        self.id = id
        self.type = type
        self.newestMessage = newestMessage
        self.createdAt = createdAt
        self.statusMessage = statusMessage
        self.isConversationOpen = isConversationOpen
        self.hasClaim = hasClaim
        self.claimType = claimType
        self.unreadMessageCount = unreadMessageCount
    }

    public var hasNewMessage: Bool {
        return unreadMessageCount > 0
    }

    public let id: String
    let type: ConversationType
    public let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?
    let isConversationOpen: Bool?
    let hasClaim: Bool
    let claimType: String?
    let unreadMessageCount: Int

    public init(
        fragment: OctopusGraphQL.ConversationFragment,
        type: ConversationType
    ) {
        self.id = fragment.id
        if let newestMessage = fragment.newestMessage?.fragments.messageFragment.asMessage() {
            self.newestMessage = .init(newestMessage)
        } else {
            self.newestMessage = nil
        }
        self.createdAt = fragment.createdAt
        self.statusMessage = fragment.statusMessage
        self.type = type
        self.isConversationOpen = fragment.isOpen
        self.hasClaim = fragment.claim != nil
        self.claimType = fragment.claim?.claimType
        self.unreadMessageCount = 0
    }

    var getConversationTitle: String {
        if self.type == .legacy {
            return L10n.chatConversationHistoryTitle
        } else if self.hasClaim {
            return L10n.chatConversationClaimTitle
        }
        return L10n.chatConversationQuestionTitle
    }

    var getConversationSubTitle: String? {
        if self.type == .legacy {
            return nil
        } else if self.hasClaim {
            if let type = self.claimType {
                return type
            }
            return nil
        }
        return nil
    }
}

public enum ConversationType: Codable, Hashable {
    case legacy
    case service
    case claim
}
