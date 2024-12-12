import Foundation
import hCore
import hCoreUI
import hGraphQL

@MainActor
public protocol AddonsClient {
    func getAddon(contractId: String) async throws -> AddonOffer
    func submitAddon(quoteId: String, addonId: String) async throws -> Date?
}

public enum AddonsError: Error {
    case emptyList
    case somethingWentWrong
    case submitError
    case errorMessage(message: String)
}

extension AddonsError: LocalizedError {
    /** TODO: ADD LOCALIZATION **/
    public var errorDescription: String? {
        switch self {
        case .somethingWentWrong:
            return "Empty list"
        case let .errorMessage(message):
            return message
        default:
            return L10n.General.errorBody
        }
    }
}
