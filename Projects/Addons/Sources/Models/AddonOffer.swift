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

public struct AddonBannerModel: Sendable, Equatable {
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
}

struct AddonDisplayItem: Equatable, Hashable {
    let displayTitle: String
    let displayValue: String
}

public struct AddonVariant: Codable, Equatable, Hashable, Sendable {
    public let displayName: String
    public let documents: [hPDFDocument]
    public let perils: [Perils]
    public let product: String
    public let termsVersion: String

    public init(
        fragment: OctopusGraphQL.AddonVariantFragment?
    ) {
        self.displayName = fragment?.displayName ?? ""
        self.documents = fragment?.documents.map({ .init($0) }) ?? []
        self.perils = fragment?.addonPerils.map({ .init(fragment: $0) }) ?? []
        self.product = fragment?.product ?? ""
        self.termsVersion = fragment?.termsVersion ?? ""
    }

    public init(
        displayName: String,
        documents: [hPDFDocument],
        perils: [Perils],
        product: String,
        termsVersion: String
    ) {
        self.displayName = displayName
        self.documents = documents
        self.perils = perils
        self.product = product
        self.termsVersion = termsVersion
    }
}
