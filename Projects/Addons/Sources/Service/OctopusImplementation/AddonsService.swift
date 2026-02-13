import AutomaticLog
import Foundation
import hCore

@MainActor public class AddonsService {
    @Inject var client: AddonsClient

    @Log
    public func getAddonOffer(contractId: String) async throws -> AddonOffer {
        try await client.getAddonOffer(contractId: contractId)
    }

    @Log
    public func getAddonOfferCost(quoteId: String, addonIds: Set<String>) async throws -> ItemCost {
        try await client.getAddonOfferCost(quoteId: quoteId, addonIds: addonIds)
    }

    @Log
    public func submitAddons(quoteId: String, selectedAddonIds: Set<String>) async throws {
        async let submit: () = try await client.submitAddons(quoteId: quoteId, addonIds: selectedAddonIds)
        async let delayTask: () = delay(3)
        let _ = try await (submit, delayTask)
    }

    @Log
    public func getAddonRemoveOffer(contractId: String) async throws -> AddonRemoveOffer {
        try await client.getAddonRemoveOffer(contractId: contractId)
    }

    @Log
    public func confirmAddonRemoval(contractId: String, addonIds: Set<String>) async throws {
        async let confirm: () = try await client.confirmAddonRemoval(contractId: contractId, addonIds: addonIds)
        async let delayTask: () = delay(3)
        let _ = try await (confirm, delayTask)
    }
}
