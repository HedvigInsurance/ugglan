import Addons
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ProductVariantComparison: Codable, Equatable, Hashable {
    let rows: [ProductVariantComparisonRow]
    let variantColumns: [ProductVariant]

    public init(
        rows: [ProductVariantComparisonRow],
        variantColumns: [ProductVariant]
    ) {
        self.rows = rows
        self.variantColumns = variantColumns
    }

    public struct ProductVariantComparisonRow: Codable, Equatable, Hashable {
        let title: String
        let description: String
        let colorCode: String?
        let cells: [ProductVariantComparisonCell]

        struct ProductVariantComparisonCell: Codable, Equatable, Hashable {
            let isCovered: Bool
            let coverageText: String?
        }
    }
}

public struct ChangeTierIntentModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let activationDate: Date
    let tiers: [Tier]
    let currentPremium: MonetaryAmount?
    let currentTier: Tier?
    let currentQuote: Quote?
    let selectedTier: Tier?
    let selectedQuote: Quote?
    let canEditTier: Bool
    let typeOfContract: TypeOfContract

    public init(
        displayName: String,
        activationDate: Date,
        tiers: [Tier],
        currentPremium: MonetaryAmount?,
        currentTier: Tier?,
        currentQuote: Quote?,
        selectedTier: Tier?,
        selectedQuote: Quote?,
        canEditTier: Bool,
        typeOfContract: TypeOfContract
    ) {
        self.displayName = displayName
        self.activationDate = activationDate
        self.tiers = tiers
        self.currentPremium = currentPremium
        self.currentTier = currentTier
        self.currentQuote = currentQuote
        self.selectedTier = selectedTier
        self.selectedQuote = selectedQuote
        self.canEditTier = canEditTier
        self.typeOfContract = typeOfContract
    }
}
public struct Tier: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: String
    let name: String
    let level: Int
    public var quotes: [Quote]
    let exposureName: String?

    public init(
        id: String,
        name: String,
        level: Int,
        quotes: [Quote],
        exposureName: String?
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.quotes = quotes
        self.exposureName = exposureName
    }

    @MainActor
    func getPremiumLabel() -> String? {
        if quotes.count == 1 {
            return quotes.first?.premium.formattedAmountPerMonth
        } else {
            if let smallestPremium = quotes.sorted(by: { $0.premium.floatAmount < $1.premium.floatAmount }).first?
                .premium
                .formattedAmountWithoutSymbol
            {
                return L10n.tierFlowPriceLabel(smallestPremium)
            }
        }
        return nil
    }
}

public struct Quote: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    let deductableAmount: MonetaryAmount?
    let deductablePercentage: Int?
    let subTitle: String?
    let premium: MonetaryAmount
    let displayItems: [DisplayItem]
    public let productVariant: ProductVariant?
    let addons: [Addon]
    public init(
        id: String,
        quoteAmount: MonetaryAmount?,
        quotePercentage: Int?,
        subTitle: String?,
        premium: MonetaryAmount,
        displayItems: [DisplayItem],
        productVariant: ProductVariant?,
        addons: [Addon]
    ) {
        self.id = id
        self.deductableAmount = quoteAmount
        self.deductablePercentage = quotePercentage
        self.subTitle = subTitle
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.addons = addons
    }

    public struct DisplayItem: Codable, Equatable, Hashable, Sendable {
        public var id = UUID()

        public init(
            title: String,
            subTitle: String?,
            value: String
        ) {
            self.title = title
            self.subTitle = subTitle
            self.value = value
        }

        let title: String
        let subTitle: String?
        let value: String
    }

    public struct Addon: Codable, Equatable, Hashable, Sendable {
        let addonId: String
        let addonVariant: AddonVariant
        let displayItems: [Quote.DisplayItem]
        let displayName: String
        let premium: MonetaryAmount
        let previousPremium: MonetaryAmount

        init(
            addonId: String,
            addonVariant: AddonVariant,
            displayItems: [Quote.DisplayItem],
            displayName: String,
            premium: MonetaryAmount,
            previousPremium: MonetaryAmount
        ) {
            self.addonId = addonId
            self.addonVariant = addonVariant
            self.displayItems = displayItems
            self.displayName = displayName
            self.premium = premium
            self.previousPremium = previousPremium
        }
    }
}

extension Quote: Equatable {
    static public func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.deductableAmount == rhs.deductableAmount && lhs.deductablePercentage == rhs.deductablePercentage
    }
}
