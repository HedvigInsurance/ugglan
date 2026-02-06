import Foundation
import hCore

/// Output type for AddonOffer mutation.
/// Returns offer with quote and addons with prices etc to show in the offer page.
public struct AddonOffer: Equatable, Sendable {
    /// Title to show in offer page.
    /// eg "Extend your coverage"
    let pageTitle: String

    /// Description to show in offer page.
    /// eg "Get extra coverage when you travel abroad"
    let pageDescription: String

    /// New quote
    let quote: AddonContractQuote

    /// Agreement total cost
    let currentTotalCost: ItemCost

    public init(
        pageTitle: String,
        pageDescription: String,
        quote: AddonContractQuote,
        currentTotalCost: ItemCost
    ) {
        self.pageTitle = pageTitle
        self.pageDescription = pageDescription
        self.quote = quote
        self.currentTotalCost = currentTotalCost
    }
}

/// Returns price for an Addon offer.
public struct AddonContractQuote: Equatable, Sendable {
    /// Id of the quote.
    let quoteId: String

    /// Display title of the addon group. eg Travel plus or Car Plus
    let displayTitle: String

    /// Display description of the addon group.
    /// eg For those who travel often: luggage protection and 24/7 assistance worldwide
    let displayDescription: String

    /// The date the addon will be activated.
    let activationDate: Date

    /// Addon Content
    ///
    /// GraphQL: `addonOffer: AddonOfferContent!`
    let addonOfferContent: AddonOfferContent

    /// List of member current addons
    let activeAddons: [ActiveAddon]

    /// Base insurance cost
    let baseQuoteCost: ItemCost

    /// Product variant
    let productVariant: ProductVariant

    public init(
        quoteId: String,
        displayTitle: String,
        displayDescription: String,
        activationDate: Date,
        addonOffer: AddonOfferContent,
        activeAddons: [ActiveAddon],
        baseQuoteCost: ItemCost,
        productVariant: ProductVariant
    ) {
        self.quoteId = quoteId
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.activationDate = activationDate
        self.addonOfferContent = addonOffer
        self.activeAddons = activeAddons
        self.baseQuoteCost = baseQuoteCost
        self.productVariant = productVariant
    }

    var addons: [AddonOfferQuote] {
        switch addonOfferContent {
        case .selectable(let addonOfferSelectable):
            addonOfferSelectable.quotes
        case .toggleable(let addonOfferToggleable):
            addonOfferToggleable.quotes
        }
    }
}

public struct ActiveAddon: Equatable, Sendable, Identifiable {
    public let id: String

    /// Cost of the existing addon.
    let cost: ItemCost

    /// Used for displaying current coverage.
    /// eg Travel Insurance Plus (45 days)
    let displayTitle: String

    /// Used for displaying current coverage.
    /// eg Risk description
    let displayDescription: String?

    public init(
        id: String,
        cost: ItemCost,
        displayTitle: String,
        displayDescription: String?
    ) {
        self.id = id
        self.cost = cost
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
    }
}

/// AddonOfferSelectable is used when we have multiple variants for the same quote
/// AddonOfferToggleable is used when we have only one variant
public enum AddonOfferContent: Equatable, Sendable {
    case selectable(AddonOfferSelectable)
    case toggleable(AddonOfferToggleable)
}

public struct AddonOfferSelectable: Equatable, Sendable, Identifiable {
    public var id: String { fieldTitle }

    /// Display title for variants
    /// eg "Maximum travel limit"
    let fieldTitle: String

    /// Info title when selecting from variants
    /// eg "Choose your maximum travel limit"
    let selectionTitle: String

    /// Info description when selecting from variants
    /// eg "Days covered when travelling"
    let selectionDescription: String

    /// Quotes for addons
    let quotes: [AddonOfferQuote]

    public init(
        fieldTitle: String,
        selectionTitle: String,
        selectionDescription: String,
        quotes: [AddonOfferQuote]
    ) {
        self.fieldTitle = fieldTitle
        self.selectionTitle = selectionTitle
        self.selectionDescription = selectionDescription
        self.quotes = quotes
    }
}

public struct AddonOfferToggleable: Equatable, Sendable {
    /// Quotes for addon
    ///
    /// GraphQL: `quotes: [AddonOfferQuote!]!`
    /// Even though this is "toggleable" (typically one variant), the schema still returns a list.
    let quotes: [AddonOfferQuote]

    public init(quotes: [AddonOfferQuote]) {
        self.quotes = quotes
    }
}

public struct AddonOfferQuote: Equatable, Sendable, Identifiable, Hashable {
    /// Id of the addon.
    public let id: String

    /// Display value of the addon. Will be shown in the select days dropdown. eg 45 days 60 days
    let displayTitle: String

    /// Display description we want to show that explains addon
    let displayDescription: String

    /// Display items of the addon.
    /// eg 'Coverage' with a value of '45 days'
    let displayItems: [AddonDisplayItem]

    /// Cost of the addon
    let cost: ItemCost

    /// Addon variant
    let addonVariant: AddonVariant

    public init(
        id: String,
        displayTitle: String,
        displayDescription: String,
        displayItems: [AddonDisplayItem],
        cost: ItemCost,
        addonVariant: AddonVariant
    ) {
        self.id = id
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.displayItems = displayItems
        self.cost = cost
        self.addonVariant = addonVariant
    }
}

public struct AddonConfig: Hashable {
    let contractId: String
    let exposureName: String
    let displayName: String

    public init(
        contractId: String,
        exposureName: String,
        displayName: String
    ) {
        self.contractId = contractId
        self.exposureName = exposureName
        self.displayName = displayName
    }
}

public struct AddonBanner: Sendable, Equatable, Codable, Hashable {
    public let contractIds: [String]
    let titleDisplayName: String
    let descriptionDisplayName: String
    let badges: [String]

    public init(
        contractIds: [String],
        titleDisplayName: String,
        descriptionDisplayName: String,
        badges: [String]
    ) {
        self.contractIds = contractIds
        self.titleDisplayName = titleDisplayName
        self.descriptionDisplayName = descriptionDisplayName
        self.badges = badges
    }
}

public struct AddonDisplayItem: Equatable, Hashable, Sendable, Codable {
    let displayTitle: String
    let displayValue: String

    public init(displayTitle: String, displayValue: String) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}
