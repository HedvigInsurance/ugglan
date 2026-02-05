import Foundation
import hCore

public struct AddonOfferV2: Equatable, Sendable {
    let pageTitle: String
    let pageDescription: String
    let quote: AddonContractQuote
    let currentTotalCost: ItemCost
}

public struct AddonContractQuote: Equatable, Sendable {
    let quoteId: String
    let displayTitle: String
    let displayDescription: String
    let activationDate: Date
    let addonOffers: [AddonOfferContent]
    let activeAddons: [ActiveAddon]
    let baseQuoteCost: ItemCost
    let productVariant: ProductVariant
}

public struct ActiveAddon: Equatable, Sendable, Identifiable {
    public let id: String
    let cost: ItemCost
    let displayTitle: String
    let displayDescription: String?
}

public enum AddonOfferContent: Equatable, Sendable {
    case selectable(AddonOfferSelectable)
    case toggleable(AddonOfferToggleable)
}

public struct AddonOfferSelectable: Equatable, Sendable, Identifiable {
    public var id: String { fieldTitle }
    let fieldTitle: String
    let selectionTitle: String
    let selectionDescription: String
    let quotes: [AddonOfferQuote]
}

public struct AddonOfferToggleable: Equatable, Sendable {
    let quote: AddonOfferQuote
}

public struct AddonOfferQuote: Equatable, Sendable, Identifiable, Hashable {
    public let id: String
    let displayTitle: String
    let displayDescription: String
    let displayItems: [AddonDisplayItem]
    let cost: ItemCost
    let addonVariant: AddonVariant
}
