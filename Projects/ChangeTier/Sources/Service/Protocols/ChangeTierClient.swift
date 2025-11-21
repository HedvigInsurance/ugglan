import Foundation
import hCore

@MainActor
public protocol ChangeTierClient {
    func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModelState
    func commitTier(quoteId: String) async throws
    func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison
}

public enum ChangeTierError: Error {
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
            return L10n.General.errorBody
        }
    }
}
