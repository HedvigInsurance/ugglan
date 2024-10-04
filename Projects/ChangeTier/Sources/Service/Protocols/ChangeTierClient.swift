import Foundation
import hCore

public protocol ChangeTierClient {
    func getTier(input: ChangeTierInput) async throws(ChangeTierError) -> ChangeTierIntentModel
    func commitTier(quoteId: String) async throws(ChangeTierError)
}

public enum ChangeTierError: Error {
    case emptyList
    case somethingWentWrong
    case commitFailed
    case networkError
    case errorMessage(message: String)
}

extension ChangeTierError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .commitFailed:
            return L10n.tierFlowCommitProcessingErrorDescription
        case let .errorMessage(message):
            return message
        default:
            return L10n.somethingWentWrong
        }
    }
}
