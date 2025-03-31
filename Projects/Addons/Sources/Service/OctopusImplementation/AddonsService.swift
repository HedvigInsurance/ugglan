import Foundation
import hCore

@MainActor
public class AddonsService {
    @Inject var service: AddonsClient

    public func getAddon(contractId: String) async throws -> AddonOffer {
        log.info("AddonsService: getAddon", error: nil, attributes: nil)
        return try await service.getAddon(contractId: contractId)
    }

    public func submitAddon(quoteId: String, addonId: String) async throws {
        log.info("AddonsService: submitAddon", error: nil, attributes: nil)
        return try await service.submitAddon(quoteId: quoteId, addonId: addonId)
    }
}
