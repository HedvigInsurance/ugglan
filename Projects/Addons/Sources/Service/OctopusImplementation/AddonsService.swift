import Foundation
import hCore

@MainActor public class AddonsService {
    @Inject var client: AddonsClient

    public func getAddonOffers(contractId: String) async throws -> AddonOffer {
        try await client.getAddonV2(contractId: contractId)
    }

    public func submitAddons(quoteId: String, selectedAddonIds: Set<String>) async throws {
        async let submit: () = try await client.submitAddons(quoteId: quoteId, addonIds: selectedAddonIds)
        async let delayTask: () = delay(3)
        let _ = try await (submit, delayTask)
    }
}
