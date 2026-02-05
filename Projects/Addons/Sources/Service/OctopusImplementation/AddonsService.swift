import Foundation
import hCore

@MainActor
public class AddonsService {
    @Inject var client: AddonsClient

    public func getAddonOffers(contractId: String) async throws -> AddonOfferV2 {
        try await client.getAddonV2(contractId: contractId)
    }

    public func submitAddons(quoteId: String, selectedAddonsIds: Set<String>) async throws {
        try await client.submitAddons(quoteId: quoteId, addonIds: selectedAddonsIds)
        await delay(3)
    }
}
