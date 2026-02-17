import Foundation
import hCore

// MARK: - Shared helpers
private func bundleDiscount(gross: Float) -> ItemDiscount {
    let discountAmount = Int(round(gross * 0.15))
    return ItemDiscount(
        campaignCode: "BUNDLE15",
        displayName: "15% bundle discount",
        displayValue: "-\(discountAmount) kr/mo",
        explanation: "Discount for bundling"
    )
}

private func cost(_ gross: Float, _ net: Float) -> ItemCost {
    .init(premium: .init(gross: .sek(gross), net: .sek(net)), discounts: [bundleDiscount(gross: gross)])
}

private func variant(_ name: String, product: String) -> AddonVariant {
    .init(displayName: name, documents: [], perils: [], product: product, termsVersion: "1.0")
}

private let activationDate = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 6))!

// MARK: - Product variants
public let travelProductVariant = ProductVariant(
    termsVersion: "1.0",
    typeOfContract: "SE_APARTMENT_RENT",
    perils: [],
    insurableLimits: [],
    documents: [],
    displayName: "Hyresrätt",
    displayNameTier: nil,
    tierDescription: nil
)

public let carProductVariant = ProductVariant(
    termsVersion: "1.0",
    typeOfContract: "SE_CAR_FULL",
    perils: [],
    insurableLimits: [],
    documents: [],
    displayName: "Bilförsäkring Hel",
    displayNameTier: nil,
    tierDescription: nil
)

// MARK: - Travel quotes
public let travelQuote45Days = AddonOfferQuote(
    id: "addon45",
    displayTitle: "45 days",
    displayDescription: "Coverage for trips up to 45 days",
    displayItems: [.init(displayTitle: "Coverage", displayValue: "45 days")],
    cost: cost(69, 59),
    addonVariant: variant("Travel Insurance Plus 45", product: "travel"),
    subType: "45 days"
)

public let travelQuote60Days = AddonOfferQuote(
    id: "addon60",
    displayTitle: "60 days",
    displayDescription: "Coverage for trips up to 60 days",
    displayItems: [.init(displayTitle: "Coverage", displayValue: "60 days")],
    cost: cost(79, 67),
    addonVariant: variant("Travel Insurance Plus 60", product: "travel"),
    subType: "60 days"
)

// MARK: - Car quotes
public let carQuoteSjalvrisk = AddonOfferQuote(
    id: "sjalvriskreducering",
    displayTitle: "Självriskreducering",
    displayDescription: "Reduce your excess in case of damage",
    displayItems: [.init(displayTitle: "Coverage", displayValue: "Excess reduction")],
    cost: cost(59, 50),
    addonVariant: variant("Självriskreducering", product: "car_addon"),
    subType: nil
)

public let carQuoteHyrbil = AddonOfferQuote(
    id: "hyrbil",
    displayTitle: "Hyrbil utomlands",
    displayDescription: "Coverage for rental cars abroad",
    displayItems: [.init(displayTitle: "Coverage", displayValue: "Rental car")],
    cost: cost(39, 33),
    addonVariant: variant("Hyrbil utomlands", product: "car_addon"),
    subType: nil
)

public let carQuoteDrulle = AddonOfferQuote(
    id: "drulle",
    displayTitle: "Drulle",
    displayDescription: "Accidental damage coverage",
    displayItems: [.init(displayTitle: "Coverage", displayValue: "Accidental damage")],
    cost: cost(29, 25),
    addonVariant: variant("Drulle", product: "car_addon"),
    subType: nil
)

// MARK: - Complete travel offers
public let testTravelOfferNoActive: AddonOffer = .init(
    pageTitle: "Extend your coverage",
    pageDescription: "Get extra coverage when you travel abroad",
    quote: .init(
        quoteId: "quoteId1",
        displayTitle: "Travel Insurance Plus",
        displayDescription: "Extra coverage when you travel abroad",
        activationDate: activationDate,
        addonOffer: .selectable(
            .init(
                fieldTitle: "Maximum travel days",
                selectionTitle: "Choose your coverage",
                selectionDescription: "Days covered when travelling",
                quotes: [travelQuote45Days, travelQuote60Days]
            )
        ),
        activeAddons: [],
        baseQuoteCost: cost(299, 254),
        productVariant: travelProductVariant
    ),
    currentTotalCost: cost(299, 254),
    infoMessage: "You're gonna lose your addons for good",
    whatsIncludedPageTitle: "What is Travel Insurance Plus?",
    whatsIncludedPageDescription: "Travel Insurance Plus is extended coverage for those who travel often"
)

public let testTravelOffer45Days: AddonOffer = .init(
    pageTitle: "Extend your coverage",
    pageDescription: "Upgrade your travel insurance for longer trips",
    quote: .init(
        quoteId: "quoteId2",
        displayTitle: "Travel Insurance Plus",
        displayDescription: "Extra coverage when you travel abroad",
        activationDate: activationDate,
        addonOffer: .selectable(
            .init(
                fieldTitle: "Maximum travel days",
                selectionTitle: "Choose your coverage",
                selectionDescription: "Days covered when travelling",
                quotes: [travelQuote60Days]
            )
        ),
        activeAddons: [
            .init(
                id: "activeAddon45",
                cost: cost(69, 59),
                displayTitle: "Travel Insurance Plus 45",
                displayDescription: "Current travel coverage"
            )
        ],
        baseQuoteCost: cost(299, 254),
        productVariant: travelProductVariant
    ),
    currentTotalCost: cost(369, 314),
    infoMessage: "Info Message",
    whatsIncludedPageTitle: "What is Travel Insurance Plus?",
    whatsIncludedPageDescription: "Travel Insurance Plus is extended coverage for those who travel often"
)

// MARK: - Complete car offers
public let testCarOfferNoActive: AddonOffer = .init(
    pageTitle: "Extend your coverage",
    pageDescription: "Get extra coverage for your car insurance",
    quote: .init(
        quoteId: "carQuoteId1",
        displayTitle: "Car Plus",
        displayDescription: "Get extra coverage for your car insurance",
        activationDate: activationDate,
        addonOffer: .toggleable(.init(quotes: [carQuoteSjalvrisk, carQuoteHyrbil, carQuoteDrulle])),
        activeAddons: [],
        baseQuoteCost: cost(469, 399),
        productVariant: carProductVariant
    ),
    currentTotalCost: cost(469, 399),
    infoMessage: "Info message",
    whatsIncludedPageTitle: "What is Car Plus?",
    whatsIncludedPageDescription: "Car Plus gives you extra protection for your car insurance"
)

public let testCarAddonRisk: AddonOffer = .init(
    pageTitle: "Extend your coverage",
    pageDescription: "Get extra coverage for your car insurance",
    quote: .init(
        quoteId: "carQuoteId2",
        displayTitle: "Car Plus",
        displayDescription: "Get extra coverage for your car insurance",
        activationDate: activationDate,
        addonOffer: .toggleable(.init(quotes: [carQuoteHyrbil, carQuoteDrulle])),
        activeAddons: [
            .init(
                id: "sjalvriskreducering",
                cost: cost(59, 50),
                displayTitle: "Självriskreducering",
                displayDescription: "Active excess reduction"
            )
        ],
        baseQuoteCost: cost(469, 399),
        productVariant: carProductVariant
    ),
    currentTotalCost: cost(529, 450),
    infoMessage: "Info message",
    whatsIncludedPageTitle: "What is Car Plus?",
    whatsIncludedPageDescription: "Car Plus gives you extra protection for your car insurance"
)

// MARK: - Remove offer
public let testRemoveOffer = AddonRemoveOffer(
    pageTitle: "Remove addon",
    pageDescription: "Select which addons you want to remove",
    currentTotalCost: .init(premium: .init(gross: .sek(529), net: .sek(450)), discounts: []),
    baseCost: .init(premium: .init(gross: .sek(469), net: .sek(399)), discounts: []),
    productVariant: carProductVariant,
    activationDate: activationDate,
    removableAddons: [
        .init(
            id: "sjalvriskreducering",
            cost: .init(premium: .init(gross: .sek(19), net: .sek(19)), discounts: []),
            displayTitle: "Självriskavdrag",
            displayDescription: "Kollision, viltolycka och bärgning"
        ),
        .init(
            id: "hyrbil",
            cost: .init(premium: .zeroSek, discounts: []),
            displayTitle: "Hyrbil",
            displayDescription: "När din egen bil inte kan användas"
        ),
    ]
)

// MARK: - Test helpers
@MainActor
public let testAddonConfig = AddonConfig(contractId: "ContractId", exposureName: "Exposure", displayName: "Insurance")

public let testAddonBanner = AddonBanner(
    contractIds: ["contractId"],
    titleDisplayName: "Travel Plus",
    descriptionDisplayName: "Extended travel insurance with extra coverage",
    badges: ["Popular"],
    addonType: .travelPlus
)

public let testAddonOfferCost = ItemCost(
    premium: .init(gross: .sek(348), net: .sek(328)),
    discounts: [.init(campaignCode: "PROMO10", displayName: "10% off", displayValue: "-20 kr/mo")]
)
