import Foundation
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
}
