import Foundation
import hCore

@MainActor
public struct Conversation: Codable, Identifiable, Hashable, Sendable {
    public init(
        id: String,
        type: ConversationType,
        newestMessage: Message?,
        createdAt: String?,
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
        return unreadMessageCount > 0
    }

    public let id: String
    let type: ConversationType
    public let newestMessage: Message?
    let createdAt: String?
    let statusMessage: String?
    let status: ConversationStatus
    let hasClaim: Bool
    let claimType: String?
    let unreadMessageCount: Int

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

    @MainActor
    public var getAnyDate: Date {
        newestMessage?.sentAt ?? createdAt?.localDateToIso8601Date ?? Date()
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
