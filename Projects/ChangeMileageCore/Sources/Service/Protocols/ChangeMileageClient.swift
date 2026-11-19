import Foundation
import hCore

@MainActor
public protocol ChangeMileageClient {
    func createIntent(contractId: String) async throws -> ChangeMileageIntent
    func commitIntent(quoteId: String) async throws
}

public enum ChangeMileageError: Error {
    case somethingWentWrong
    /// A message from the backend explaining why the mileage can't be changed, meant to be shown as is.
    case userError(message: String)
}

extension ChangeMileageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .userError(message): return message
        case .somethingWentWrong: return L10n.General.errorBody
        }
    }
}
