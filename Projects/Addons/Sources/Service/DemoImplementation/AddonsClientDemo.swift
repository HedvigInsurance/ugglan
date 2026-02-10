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

    public func getAddonRemoveOffer(contractId: String) async throws -> AddonRemoveOffer {
        await delay(TimeInterval.random(in: 0.5...1.5))
        return AddonRemoveOffer(
            pageTitle: "Remove addon",
            pageDescription: "Select which addons you want to remove",
            currentTotalCost: .init(premium: .init(gross: .sek(529), net: .sek(450)), discounts: []),
            baseCost: .init(premium: .init(gross: .sek(469), net: .sek(399)), discounts: []),
            productVariant: .init(
                termsVersion: "1.0",
                typeOfContract: "SE_CAR_FULL",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "Bilförsäkring Hel",
                displayNameTier: nil,
                tierDescription: nil
            ),
            activationDate: Date(),
            removableAddons: [
                ActiveAddon(
                    id: "sjalvriskreducering",
                    cost: .init(premium: .init(gross: .sek(59), net: .sek(50)), discounts: []),
                    displayTitle: "Självriskreducering",
                    displayDescription: "Reduces your excess in case of a claim"
                )
            ]
        )
    }

    public func confirmAddonRemoval(contractId: String, addonIds: [String]) async throws {
        await delay(TimeInterval.random(in: 0.5...1.5))
    }

    public init() {
        self.offer = testTravelOfferNoActive
    }
    public init(offer: AddonOffer) {
        self.offer = offer
    }
}
