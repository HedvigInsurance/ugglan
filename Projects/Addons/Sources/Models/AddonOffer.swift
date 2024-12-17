import Foundation
import hCore
import hGraphQL

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

public struct AddonBannerModel {
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
        self.title = titleDisplayName
        self.description = description
        self.activationDate = activationDate
        self.currentAddon = currentAddon
        self.quotes = quotes
    }
}

public struct AddonQuote: Identifiable, Equatable, Hashable, Sendable {
    public var id: String {
        addonId
    }
    let displayName: String?
    let quoteId: String
    let addonId: String
    let displayItems: [AddonDisplayItem]
    let price: MonetaryAmount?
    let productVariant: ProductVariant
}

struct AddonDisplayItem: Equatable, Hashable {
    let displayTitle: String
    let displayValue: String
}
