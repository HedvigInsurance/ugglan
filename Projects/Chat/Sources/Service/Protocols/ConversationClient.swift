import Foundation
import hCore
import hCoreUI

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
    func escalateChatMessage(reference: String) async throws -> Message?
}

public struct ConversationMessagesData {
    let messages: [Message]
    let banner: Markdown?
    let olderToken: String?
    let newerToken: String?
    let isConversationOpen: Bool?
    let createdAt: String?
    let isLegacy: Bool
    let hasClaim: Bool
    let claimType: String?
    let claimId: String?

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
        claimId: String?
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
    }

    var screenTitle: String {
        if isLegacy {
            return L10n.chatConversationHistoryTitle
        } else if hasClaim {
            return claimType ?? L10n.chatConversationClaimTitle
        }
        return L10n.chatConversationQuestionTitle
    }

    @MainActor
    var subtitle: String? {
        if isLegacy { return nil }
        guard let date = createdAt?.localDateToIso8601Date?.displayDateDDMMMYYYYFormat else {
            return nil
        }
        return "\(L10n.ClaimStatusDetail.submitted) \(date)"
    }
}
