import Foundation
import hCore
import hCoreUI
import hGraphQL

@MainActor
public protocol AddonsClient {
    func getAddon(contractId: String, source: AddonSource) async throws -> AddonOffer
    func submitAddon(quoteId: String, addonId: String) async throws
}

public enum AddonsError: Error {
    case somethingWentWrong
    case submitError
    case errorMessage(message: String)
}

extension AddonsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .somethingWentWrong:
            return L10n.somethingWentWrong
        case let .errorMessage(message):
            return message
        default:
            return L10n.General.errorBody
        }
    }
}
