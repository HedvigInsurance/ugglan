import AutomaticLog
import Foundation
import hCore

@MainActor public class AddonsService {
    @Inject var client: AddonsClient

    @Log
    public func getAddonOffer(contractInfo: AddonContractInfo, source: AddonSource) async throws -> AddonOfferData {
        try await client.getAddonOffer(contractInfo: contractInfo, source: source)
    }

    @Log
    public func getAddonOfferCost(quoteId: String, addonIds: Set<String>) async throws -> ItemCost {
        try await client.getAddonOfferCost(quoteId: quoteId, addonIds: addonIds)
    }

    @Log
    public func getAddonRemoveOfferCost(contractId: String, addonIds: Set<String>) async throws -> ItemCost {
        try await client.getAddonRemoveOfferCost(contractId: contractId, addonIds: addonIds)
    }

    @Log
    public func submitAddons(quoteId: String, selectedAddonIds: Set<String>) async throws {
        try await Task.withMinimumDuration(.seconds(3)) {
            try await client.submitAddons(quoteId: quoteId, addonIds: selectedAddonIds)
        }
    }

    @Log
    public func getAddonRemoveOffer(contractInfo: AddonContractInfo) async throws -> AddonRemoveOffer {
        try await client.getAddonRemoveOffer(contractInfo: contractInfo)
    }

    @Log
    public func confirmAddonRemoval(contractId: String, addonIds: Set<String>) async throws {
        try await Task.withMinimumDuration(.seconds(3)) {
            try await client.confirmAddonRemoval(contractId: contractId, addonIds: addonIds)
        }
    }
}
