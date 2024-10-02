import Foundation
import hCore

public protocol ChangeTierClient {
    func getTier(
        contractId: String,
        tierSource: ChangeTierSource
    ) async throws(ChangeTierError) -> ChangeTierIntentModel
    func commitTier(quoteId: String) async throws(ChangeTierError)
}

public enum ChangeTierError: Error {
    case emptyList
    case somethingWentWrong
    case networkError
    case errorMessage(message: String)
}

extension ChangeTierError: LocalizedError {
    public var errorDescription: String? {
        return L10n.somethingWentWrong
    }
}
