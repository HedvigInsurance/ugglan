import Foundation
import hCore
import hGraphQL

public struct AddonBannerModel {
    let contractIds: [String]
    let titleDisplayName: String
    let descriptionDisplayName: String
    let isPopular: Bool

    public init(
        contractIds: [String],
        titleDisplayName: String,
        descriptionDisplayName: String,
        isPopular: Bool
    ) {
        self.contractIds = contractIds
        self.titleDisplayName = titleDisplayName
        self.descriptionDisplayName = descriptionDisplayName
        self.isPopular = isPopular
    }
}

public struct AddonOffer: Identifiable, Equatable, Hashable, Sendable {
    public let id = UUID()
    let title: String
    let description: String?
    let activationDate: Date?
    let quotes: [AddonQuote]

    public init(
        titleDisplayName: String,
        description: String?,
        activationDate: Date?,
        quotes: [AddonQuote]
    ) {
        self.title = titleDisplayName
        self.description = description
        self.activationDate = activationDate
        self.quotes = quotes
    }
}

public struct AddonQuote: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    let displayName: String?
    let quoteId: String
    let addonId: String
    let price: MonetaryAmount?
    let productVariant: ProductVariant
}
