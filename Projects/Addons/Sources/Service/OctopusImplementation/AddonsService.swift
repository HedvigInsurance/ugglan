import Foundation
import hCore

@MainActor
public class AddonsService {
    @Inject var client: AddonsClient

    public func getAddonOffers(contractId: String) async throws -> AddonOfferV2 {
        try await client.getAddonV2(contractId: contractId)
    }

    public func submitAddons(quoteId: String, selectedAddonIds: Set<String>) async throws {
        try await client.submitAddons(quoteId: quoteId, addonIds: selectedAddonIds)
        await delay(3)
    }
}
