import Foundation
import hCore

public enum ConversationsError: Error {
    case errorMesage(message: String)
    case missingData
    case uploadFailed
    case missingConversation
}

extension ConversationsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .errorMesage(message): return message
        case .missingData: return L10n.somethingWentWrong
        case .uploadFailed: return L10n.somethingWentWrong
        case .missingConversation: return L10n.somethingWentWrong
        }
    }
}
