import Foundation
import hCore

@MainActor
public protocol ConversationsClient {
    func getConversations() async throws -> [Conversation]
    func createConversation(with id: UUID) async throws -> Conversation
}

@MainActor
public protocol ConversationClient {
    func getConversationMessages(
        for conversationId: String,
        olderToken: String?,
        newerToken: String?
    ) async throws -> ConversationMessagesData
    func send(message: Message, for conversationId: String) async throws -> Message
    func hideCrossSales(for conversationId: String) async throws
}

public struct ConversationMessagesData {
    public let messages: [Message]
    public let banner: Markdown?
    public let olderToken: String?
    public let newerToken: String?
    public let isConversationOpen: Bool?
    public let createdAt: String?
    public let isLegacy: Bool
    public let hasClaim: Bool
    public let claimType: String?
    public let claimId: String?
    public let responseIsBeingGenerated: Bool
    public let showCrossSales: Bool
    public init(
        messages: [Message],
        banner: Markdown?,
        olderToken: String?,
        newerToken: String?,
        isConversationOpen: Bool?,
        createdAt: String?,
        isLegacy: Bool,
        hasClaim: Bool,
        claimType: String?,
        claimId: String?,
        responseIsBeingGenerated: Bool,
        showCrossSales: Bool = false
    ) {
        self.messages = messages
        self.banner = banner
        self.olderToken = olderToken
        self.newerToken = newerToken
        self.isConversationOpen = isConversationOpen
        self.createdAt = createdAt
        self.isLegacy = isLegacy
        self.hasClaim = hasClaim
        self.claimType = claimType
        self.claimId = claimId
        self.responseIsBeingGenerated = responseIsBeingGenerated
        self.showCrossSales = showCrossSales
    }

    public var screenTitle: String {
        if isLegacy {
            return L10n.chatConversationHistoryTitle
        } else if hasClaim {
            return claimType ?? L10n.chatConversationClaimTitle
        }
        return L10n.chatConversationQuestionTitle
    }

    @MainActor
    public var subtitle: String? {
        if isLegacy { return nil }
        guard let date = createdAt?.localDateToIso8601Date?.displayDateDDMMMYYYYFormat else {
            return nil
        }
        return "\(L10n.ClaimStatusDetail.submitted) \(date)"
    }
}
