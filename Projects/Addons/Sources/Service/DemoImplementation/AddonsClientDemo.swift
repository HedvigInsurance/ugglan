import Foundation
import hCore

public class AddonsClientDemo: AddonsClient {
    public func getAddonV2(contractId: String) async throws -> AddonOfferV2 {
        await delay(TimeInterval.random(in: 0.5...1.5))
        return testOffer45Days
    }

    public func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
        await delay(TimeInterval.random(in: 0.5...1.5))
    }

    public init() {}
}

public let testOfferNoAddons: AddonOfferV2 = {
    let bundleDiscount45 = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-10 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )

    let quote45 = AddonOfferQuote(
        id: "addon45",
        displayTitle: "45 days",
        displayDescription: "Coverage for trips up to 45 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "45 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(
            premium: .init(gross: .sek(69), net: .sek(59)),
            discounts: [bundleDiscount45]
        ),
        addonVariant: .init(
            displayName: "Travel Plus 45",
            documents: [],
            perils: [],
            product: "travel",
            termsVersion: "1.0"
        )
    )

    let bundleDiscount60 = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-10 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )

    let quote60 = AddonOfferQuote(
        id: "addon60",
        displayTitle: "60 days",
        displayDescription: "Coverage for trips up to 60 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "60 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(
            premium: .init(gross: .sek(79), net: .sek(69)),
            discounts: [bundleDiscount60]
        ),
        addonVariant: .init(
            displayName: "Travel Plus 60",
            documents: [],
            perils: [],
            product: "travel",
            termsVersion: "1.0"
        )
    )

    let selectable = AddonOfferSelectable(
        fieldTitle: "Maximum travel days",
        selectionTitle: "Choose your coverage",
        selectionDescription: "Days covered when travelling",
        quotes: [quote45, quote60]
    )

    return AddonOfferV2(
        pageTitle: "Extend your coverage",
        pageDescription: "Get extra coverage when you travel abroad",
        quote: AddonContractQuote(
            quoteId: "quoteId1",
            displayTitle: "Travel Plus",
            displayDescription: "For those who travel often: luggage protection and 24/7 assistance worldwide",
            activationDate: Date(),
            addonOffers: [.selectable(selectable)],
            activeAddons: [],
            baseQuoteCost: .init(premium: .init(gross: .sek(299), net: .sek(279)), discounts: []),
            productVariant: .init(
                termsVersion: "1.0",
                typeOfContract: "SE_APARTMENT_RENT",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "Hyresrätt",
                displayNameTier: nil,
                tierDescription: nil
            )
        ),
        currentTotalCost: .init(
            premium: .init(gross: .sek(299), net: .sek(249)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-50 kr/mo",
                    explanation: "Discount for bundling addons with your home insurance"
                )
            ]
        )
    )
}()

public let testOffer45Days: AddonOfferV2 = {
    let bundleDiscount = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-10 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )

    let quote60 = AddonOfferQuote(
        id: "addon60",
        displayTitle: "Travel Plus 60",
        displayDescription: "Coverage for trips up to 60 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "60 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(
            premium: .init(gross: .sek(79), net: .sek(69)),
            discounts: [bundleDiscount]
        ),
        addonVariant: .init(
            displayName: "Travel Plus 60",
            documents: [],
            perils: [],
            product: "travel",
            termsVersion: "1.0"
        )
    )

    let selectable = AddonOfferSelectable(
        fieldTitle: "Maximum travel days",
        selectionTitle: "Choose your coverage",
        selectionDescription: "Days covered when travelling",
        quotes: [quote60]
    )

    let activeAddon = ActiveAddon(
        id: "activeAddon45",
        cost: .init(
            premium: .init(gross: .sek(69), net: .sek(59)),
            discounts: [bundleDiscount]
        ),
        displayTitle: "Travel Plus 45",
        displayDescription: "Current travel coverage"
    )

    return AddonOfferV2(
        pageTitle: "Extend your coverage",
        pageDescription: "Upgrade your travel insurance for longer trips",
        quote: AddonContractQuote(
            quoteId: "quoteId2",
            displayTitle: "Travel Plus",
            displayDescription: "For those who travel often: luggage protection and 24/7 assistance worldwide",
            activationDate: Date(),
            addonOffers: [.selectable(selectable)],
            activeAddons: [activeAddon],
            baseQuoteCost: .init(premium: .init(gross: .sek(299), net: .sek(279)), discounts: []),
            productVariant: .init(
                termsVersion: "1.0",
                typeOfContract: "SE_APARTMENT_RENT",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "Hyresrätt",
                displayNameTier: nil,
                tierDescription: nil
            )
        ),
        currentTotalCost: .init(
            premium: .init(gross: .sek(369), net: .sek(319)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-50 kr/mo",
                    explanation: "Discount for bundling addons with your home insurance"
                )
            ]
        )
    )
}()
