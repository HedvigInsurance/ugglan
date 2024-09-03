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
        hasNewMessage: Bool
    ) {
        self.id = id
        self.type = type
        self.newestMessage = newestMessage
        self.createdAt = createdAt
        self.statusMessage = statusMessage
        self.isConversationOpen = isConversationOpen
        self.hasClaim = hasClaim
        self.claimType = claimType
        self.hasNewMessage = hasNewMessage
    }

    public let id: String
    let type: ConversationType
    public let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?
    let isConversationOpen: Bool?
    let hasClaim: Bool
    let claimType: String?
    public let hasNewMessage: Bool

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
        self.hasNewMessage = Bool.random()
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
