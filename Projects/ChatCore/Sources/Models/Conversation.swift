import Foundation
import hCore

@MainActor
public struct Conversation: Codable, Identifiable, Hashable, Sendable {
    public init(
        id: String,
        type: ConversationType,
        newestMessage: Message?,
        createdAt: Date,
        statusMessage: String?,
        status: ConversationStatus,
        hasClaim: Bool,
        claimType: String?,
        unreadMessageCount: Int
    ) {
        self.id = id
        self.type = type
        self.newestMessage = newestMessage
        self.createdAt = createdAt
        self.statusMessage = statusMessage
        self.status = status
        self.hasClaim = hasClaim
        self.claimType = claimType
        self.unreadMessageCount = unreadMessageCount
    }

    public var hasNewMessage: Bool {
        unreadMessageCount > 0
    }

    public let id: String
    public let type: ConversationType
    public let newestMessage: Message?
    public let createdAt: Date
    public let statusMessage: String?
    public let status: ConversationStatus
    public let hasClaim: Bool
    public let claimType: String?
    public let unreadMessageCount: Int

    public var getConversationTitle: String {
        if type == .legacy {
            return L10n.chatConversationHistoryTitle
        } else if hasClaim {
            return L10n.chatConversationClaimTitle
        }
        return L10n.chatConversationQuestionTitle
    }

    public var getConversationSubTitle: String? {
        if type == .legacy {
            return nil
        } else if hasClaim {
            if let type = claimType {
                return type
            }
            return nil
        }
        return nil
    }

    @MainActor
    public var timestamp: Date {
        newestMessage?.sentAt ?? createdAt
    }

    public var isOpened: Bool {
        status == .open
    }

    public var isClosed: Bool {
        status == .closed
    }
}

public enum ConversationType: Codable, Hashable, Sendable {
    case legacy
    case service
    case claim
}

public enum ConversationStatus: Codable, Hashable, Sendable {
    case open
    case closed
}
