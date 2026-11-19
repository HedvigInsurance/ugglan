import Foundation
import hCore

@MainActor
public protocol MessagesClient {
    func getMessages() async throws -> [InboxMessage]
    func markAsRead(messageId: String) async throws
}

public enum MessagesError: Error {
    case notImplemented
}

extension MessagesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return L10n.General.errorBody
        }
    }
}
