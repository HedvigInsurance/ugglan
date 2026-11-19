import Foundation
import hCore

@MainActor
public protocol MessagesClient {
    /// The inbox without message bodies; those are fetched one at a time with `getMessageContent`.
    func getMessages() async throws -> [InboxMessage]
    func getMessageContent(messageId: String) async throws -> InboxMessageContent
}

public enum MessagesError: Error {
    case missingBody
}

extension MessagesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingBody:
            return L10n.General.errorBody
        }
    }
}
