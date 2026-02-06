import Foundation
import hCore

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

public struct AddonBannerModel: Sendable, Equatable, Codable, Hashable {
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

public struct AddonOffer: Identifiable, Equatable, Hashable, Sendable {
    public let id = UUID()
    public let title: String
    let description: String?
    let activationDate: Date?
    public let currentAddon: AddonQuote?
    let quotes: [AddonQuote]

    public init(
        titleDisplayName: String,
        description: String?,
        activationDate: Date?,
        currentAddon: AddonQuote?,
        quotes: [AddonQuote]
    ) {
        title = titleDisplayName
        self.description = description
        self.activationDate = activationDate
        self.currentAddon = currentAddon
        self.quotes = quotes
    }

    func getTotalPrice(selectedQuote: AddonQuote?) -> MonetaryAmount? {
        guard let selectedQuote else { return nil }
        guard let currentAddon else { return selectedQuote.itemCost.premium.net }
        let currentAddonPrice = currentAddon.itemCost.premium.net
        let newPrice = selectedQuote.itemCost.premium.net

        return newPrice - currentAddonPrice
    }
}

public struct AddonQuote: Identifiable, Equatable, Hashable, Codable, Sendable {
    public var id: String {
        addonId
    }

    public let displayName: String?
    let displayNameLong: String
    let quoteId: String
    let addonId: String
    public let addonSubtype: String
    let displayItems: [AddonDisplayItem]
    public let itemCost: ItemCost
    let addonVariant: AddonVariant?
    let documents: [hPDFDocument]

    public init(
        displayName: String?,
        displayNameLong: String,
        quoteId: String,
        addonId: String,
        addonSubtype: String,
        displayItems: [AddonDisplayItem],
        itemCost: ItemCost,
        addonVariant: AddonVariant?,
        documents: [hPDFDocument]
    ) {
        self.displayName = displayName
        self.displayNameLong = displayNameLong
        self.quoteId = quoteId
        self.addonId = addonId
        self.addonSubtype = addonSubtype
        self.displayItems = displayItems
        self.itemCost = itemCost
        self.addonVariant = addonVariant
        self.documents = documents
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
