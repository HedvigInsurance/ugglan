import Foundation
import hCore

public class AddonsClientDemo: AddonsClient {
    let offer: AddonOffer

    public func getAddonV2(contractId: String) async throws -> AddonOffer {
        await delay(TimeInterval.random(in: 0.5...1.5))
        return offer
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

public let testTravelOfferNoActive: AddonOffer = {
    let d45 = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-10 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )
    let q45 = AddonOfferQuote(
        id: "addon45",
        displayTitle: "45 days",
        displayDescription: "Coverage for trips up to 45 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "45 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(premium: .init(gross: .sek(69), net: .sek(59)), discounts: [d45]),
        addonVariant: .init(
            displayName: "Travel Insurance Plus 45",
            documents: [],
            perils: [],
            product: "travel",
            termsVersion: "1.0"
        )
    )

    let d60 = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-12 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )
    let q60 = AddonOfferQuote(
        id: "addon60",
        displayTitle: "60 days",
        displayDescription: "Coverage for trips up to 60 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "60 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(premium: .init(gross: .sek(79), net: .sek(67)), discounts: [d60]),
        addonVariant: .init(
            displayName: "Travel Insurance Plus 60",
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
        quotes: [q45, q60]
    )

    return .init(
        pageTitle: "Extend your coverage",
        pageDescription: "Get extra coverage when you travel abroad",
        quote: .init(
            quoteId: "quoteId1",
            displayTitle: "Travel Insurance Plus",
            displayDescription: "Extra coverage when you travel abroad",
            activationDate: Date(),
            addonOffer: .selectable(selectable),
            activeAddons: [],
            baseQuoteCost: .init(premium: .init(gross: .sek(299), net: .sek(254)), discounts: []),
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
            premium: .init(gross: .sek(299), net: .sek(254)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-45 kr/mo",
                    explanation: "Discount for bundling addons with your home insurance"
                )
            ]
        ),
        addonType: .travel
    )
}()

public let testTravelOffer45Days: AddonOffer = {
    let d60 = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-12 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )
    let q60 = AddonOfferQuote(
        id: "addon60",
        displayTitle: "60 days",
        displayDescription: "Coverage for trips up to 60 days",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "60 days"),
            .init(displayTitle: "Insured people", displayValue: "You+1"),
        ],
        cost: .init(premium: .init(gross: .sek(79), net: .sek(67)), discounts: [d60]),
        addonVariant: .init(
            displayName: "Travel Insurance Plus 60",
            documents: [],
            perils: [],
            product: "travel",
            termsVersion: "1.0"
        )
    )

    let activeD = ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-10 kr/mo",
        explanation: "Discount for bundling with your home insurance"
    )
    let active = ActiveAddon(
        id: "activeAddon45",
        cost: .init(premium: .init(gross: .sek(69), net: .sek(59)), discounts: [activeD]),
        displayTitle: "Travel Insurance Plus 45",
        displayDescription: "Current travel coverage"
    )

    return .init(
        pageTitle: "Extend your coverage",
        pageDescription: "Upgrade your travel insurance for longer trips",
        quote: .init(
            quoteId: "quoteId2",
            displayTitle: "Travel Insurance Plus",
            displayDescription: "Extra coverage when you travel abroad",
            activationDate: Date(),
            addonOffer: .selectable(
                .init(
                    fieldTitle: "Maximum travel days",
                    selectionTitle: "Choose your coverage",
                    selectionDescription: "Days covered when travelling",
                    quotes: [q60]
                )
            ),
            activeAddons: [active],
            baseQuoteCost: .init(premium: .init(gross: .sek(299), net: .sek(254)), discounts: []),
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
            premium: .init(gross: .sek(369), net: .sek(314)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-55 kr/mo",
                    explanation: "Discount for bundling addons with your home insurance"
                )
            ]
        ),
        addonType: .travel
    )
}()

public let testCarOfferNoActive: AddonOffer = {
    let exp = "Discount for bundling with your car insurance"

    let sj = AddonOfferQuote(
        id: "sjalvriskreducering",
        displayTitle: "Självriskreducering",
        displayDescription: "Lorem ipsum dolor lurem imne",
        displayItems: [.init(displayTitle: "Coverage", displayValue: "Excess reduction")],
        cost: .init(
            premium: .init(gross: .sek(59), net: .sek(50)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-9 kr/mo",
                    explanation: exp
                )
            ]
        ),
        addonVariant: .init(
            displayName: "Självriskreducering",
            documents: [],
            perils: [],
            product: "car_addon",
            termsVersion: "1.0"
        )
    )
    let hyr = AddonOfferQuote(
        id: "hyrbil",
        displayTitle: "Hyrbil utomlands",
        displayDescription: "Lorem ipsum dolor lurem imne",
        displayItems: [.init(displayTitle: "Coverage", displayValue: "Rental car")],
        cost: .init(
            premium: .init(gross: .sek(39), net: .sek(33)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-6 kr/mo",
                    explanation: exp
                )
            ]
        ),
        addonVariant: .init(
            displayName: "Hyrbil utomlands",
            documents: [],
            perils: [],
            product: "car_addon",
            termsVersion: "1.0"
        )
    )
    let dr = AddonOfferQuote(
        id: "drulle",
        displayTitle: "Drulle",
        displayDescription: "Lorem ipsum dolor lurem imne",
        displayItems: [.init(displayTitle: "Coverage", displayValue: "Accidental damage")],
        cost: .init(
            premium: .init(gross: .sek(29), net: .sek(25)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-4 kr/mo",
                    explanation: exp
                )
            ]
        ),
        addonVariant: .init(displayName: "Drulle", documents: [], perils: [], product: "car_addon", termsVersion: "1.0")
    )

    return .init(
        pageTitle: "Extend your coverage",
        pageDescription: "Get extra coverage for your car insurance",
        quote: .init(
            quoteId: "carQuoteId1",
            displayTitle: "Car Plus",
            displayDescription: "Get extra coverage for your car insurance",
            activationDate: Date(),
            addonOffer: .toggleable(.init(quotes: [sj, hyr, dr])),
            activeAddons: [],
            baseQuoteCost: .init(premium: .init(gross: .sek(469), net: .sek(399)), discounts: []),
            productVariant: .init(
                termsVersion: "1.0",
                typeOfContract: "SE_CAR_FULL",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "Bilförsäkring Hel",
                displayNameTier: nil,
                tierDescription: nil
            )
        ),
        currentTotalCost: .init(
            premium: .init(gross: .sek(469), net: .sek(399)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-70 kr/mo",
                    explanation: "Discount for bundling addons with your car insurance"
                )
            ]
        ),
        addonType: .car
    )
}()

public let testCarAddonRisk: AddonOffer = {
    let exp = "Discount for bundling with your car insurance"

    let active = ActiveAddon(
        id: "sjalvriskreducering",
        cost: .init(
            premium: .init(gross: .sek(59), net: .sek(50)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-9 kr/mo",
                    explanation: exp
                )
            ]
        ),
        displayTitle: "Självriskreducering",
        displayDescription: "Lorem ipsum dolor lurem imne"
    )

    let hyr = AddonOfferQuote(
        id: "hyrbil",
        displayTitle: "Hyrbil utomlands",
        displayDescription: "Lorem ipsum dolor lurem imne",
        displayItems: [.init(displayTitle: "Coverage", displayValue: "Rental car")],
        cost: .init(
            premium: .init(gross: .sek(39), net: .sek(33)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-6 kr/mo",
                    explanation: exp
                )
            ]
        ),
        addonVariant: .init(
            displayName: "Hyrbil utomlands",
            documents: [],
            perils: [],
            product: "car_addon",
            termsVersion: "1.0"
        )
    )
    let dr = AddonOfferQuote(
        id: "drulle",
        displayTitle: "Drulle",
        displayDescription: "Lorem ipsum dolor lurem imne",
        displayItems: [.init(displayTitle: "Coverage", displayValue: "Accidental damage")],
        cost: .init(
            premium: .init(gross: .sek(29), net: .sek(25)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-4 kr/mo",
                    explanation: exp
                )
            ]
        ),
        addonVariant: .init(displayName: "Drulle", documents: [], perils: [], product: "car_addon", termsVersion: "1.0")
    )

    return .init(
        pageTitle: "Extend your coverage",
        pageDescription: "Get extra coverage for your car insurance",
        quote: .init(
            quoteId: "carQuoteId2",
            displayTitle: "Car Plus",
            displayDescription: "Get extra coverage for your car insurance",
            activationDate: Date(),
            addonOffer: .toggleable(.init(quotes: [hyr, dr])),
            activeAddons: [active],
            baseQuoteCost: .init(premium: .init(gross: .sek(469), net: .sek(399)), discounts: []),
            productVariant: .init(
                termsVersion: "1.0",
                typeOfContract: "SE_CAR_FULL",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "Bilförsäkring Hel",
                displayNameTier: nil,
                tierDescription: nil
            )
        ),
        currentTotalCost: .init(
            premium: .init(gross: .sek(529), net: .sek(450)),
            discounts: [
                ItemDiscount(
                    campaignCode: "BUNDLE15",
                    displayName: "15% bundle discount",
                    displayValue: "-79 kr/mo",
                    explanation: "Discount for bundling addons with your car insurance"
                )
            ]
        ),
        addonType: .car
    )
}()
