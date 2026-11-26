import Foundation
import hCore

public struct ChatData: Sendable {
    public let conversationId: String
    public let hasPreviousMessage: Bool
    public let messages: [Message]
    public let banner: Markdown?
    public let conversationStatus: ConversationStatus?
    public let title: String?
    public let subtitle: String?
    public let claimId: String?
    public let responseIsBeingGenerated: Bool
    public let showCrossSales: Bool

    public init(
        conversationId: String,
        hasPreviousMessage: Bool,
        messages: [Message],
        banner: Markdown?,
        conversationStatus: ConversationStatus?,
        title: String?,
        subtitle: String?,
        claimId: String?,
        responseIsBeingGenerated: Bool,
        showCrossSales: Bool
    ) {
        self.conversationId = conversationId
        self.hasPreviousMessage = hasPreviousMessage
        self.messages = messages
        self.banner = banner
        self.conversationStatus = conversationStatus
        self.title = title
        self.subtitle = subtitle
        self.claimId = claimId
        self.responseIsBeingGenerated = responseIsBeingGenerated
        self.showCrossSales = showCrossSales
    }
}
