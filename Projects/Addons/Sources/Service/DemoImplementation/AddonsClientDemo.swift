import Foundation
import hCore

public class AddonsClientDemo: AddonsClient {
    let offer: AddonOffer

    public func getAddonOffer(contractId: String) async throws -> AddonOffer {
        await delay(TimeInterval.random(in: 0.5...1.5))
        return offer
    }

    public func getAddonOfferCost(quoteId: String, addonIds: Set<String>) async throws -> ItemCost {
        await delay(TimeInterval.random(in: 0.5...1.5))
        return .init(
            premium: .init(gross: .sek(129), net: .sek(110)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-19 kr/mo",
                    explanation: "Discount for bundling addons"
                )
            ]
        )
    }

    public func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
        await delay(TimeInterval.random(in: 0.5...1.5))
    }

    public func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        []
    }

    public init() {
        self.offer = testTravelOfferNoActive
    }
    public init(offer: AddonOffer) {
        self.offer = offer
    }
}
