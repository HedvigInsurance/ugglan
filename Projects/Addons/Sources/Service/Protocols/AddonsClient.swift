import Foundation
import hCore

@MainActor
public protocol AddonsClient {
    func getAddon(contractId: String) async throws -> AddonOffer
    func submitAddon(quoteId: String, addonId: String) async throws
}

public enum AddonsError: Error {
    case somethingWentWrong
    case submitError
    case errorMessage(message: String)
    case missingContracts
}

extension AddonsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .somethingWentWrong:
            return L10n.General.errorBody
        case let .errorMessage(message):
            return message
        case .missingContracts:
            return L10n.General.defaultError
        default:
            return L10n.General.errorBody
        }
    }
}
