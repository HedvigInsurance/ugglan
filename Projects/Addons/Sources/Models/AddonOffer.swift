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
    let title: String
    let description: String?
    let activationDate: Date?
    let currentAddon: AddonQuote?
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
        guard let currentAddon else { return selectedQuote.price }
        guard let currentAddonPrice = currentAddon.price,
            let newPrice = selectedQuote.price
        else { return nil }
        let diffPrice = newPrice.value - currentAddonPrice.value
        return MonetaryAmount(amount: diffPrice.asString, currency: newPrice.currency)
    }
}

public struct AddonQuote: Identifiable, Equatable, Hashable, Sendable {
    public var id: String {
        addonId
    }

    let displayName: String?
    let quoteId: String
    let addonId: String
    let addonSubtype: String
    let displayItems: [AddonDisplayItem]
    let price: MonetaryAmount?
    let addonVariant: AddonVariant?
    let documents: [hPDFDocument]

    public init(
        displayName: String?,
        quoteId: String,
        addonId: String,
        addonSubtype: String,
        displayItems: [AddonDisplayItem],
        price: MonetaryAmount?,
        addonVariant: AddonVariant?,
        documents: [hPDFDocument]
    ) {
        self.displayName = displayName
        self.quoteId = quoteId
        self.addonId = addonId
        self.addonSubtype = addonSubtype
        self.displayItems = displayItems
        self.price = price
        self.addonVariant = addonVariant
        self.documents = documents
    }
}

public struct AddonDisplayItem: Equatable, Hashable, Sendable {
    let displayTitle: String
    let displayValue: String

    public init(displayTitle: String, displayValue: String) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}
