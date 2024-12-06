import Foundation
import hCore
import hGraphQL

public struct AddonBannerModel {
    let contractIds: [String]
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
    public let id: String
    let displayName: String?
    let quoteId: String
    let addonId: String
    let displayItems: [AddonDisplayItem]
    let price: MonetaryAmount?
    let productVariant: ProductVariant

    struct AddonDisplayItem: Equatable, Hashable {
        let displayTitle: String
        let displaySubtitle: String?
        let displayValue: String
    }
}