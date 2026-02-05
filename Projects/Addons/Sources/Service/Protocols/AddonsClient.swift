import Foundation
import hCore

@MainActor
public protocol AddonsClient {
    func getAddonV2(contractId: String) async throws -> AddonOffer
    func submitAddons(quoteId: String, addonIds: Set<String>) async throws
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner]
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
