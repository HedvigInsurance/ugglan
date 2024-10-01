import Foundation
import hCore

public protocol ChangeTierClient {
    func getTier(
        contractId: String,
        tierSource: ChangeTierSource
    ) async throws(ChangeTierError) -> ChangeTierIntentModel
}

public enum ChangeTierError: Error {
    case emptyList
    case somethingWentWrong
    case networkError
}

extension ChangeTierError: LocalizedError {
    public var errorDescription: String? {
        return L10n.somethingWentWrong
    }
}
