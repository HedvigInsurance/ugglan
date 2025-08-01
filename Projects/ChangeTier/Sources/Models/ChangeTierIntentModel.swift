import Addons
import Foundation
import hCore
import hCoreUI

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

        public init(title: String, description: String, colorCode: String?, cells: [ProductVariantComparisonCell]) {
            self.title = title
            self.description = description
            self.colorCode = colorCode
            self.cells = cells
        }

        public struct ProductVariantComparisonCell: Codable, Equatable, Hashable {
            let isCovered: Bool
            let coverageText: String?

            public init(isCovered: Bool, coverageText: String?) {
                self.isCovered = isCovered
                self.coverageText = coverageText
            }
        }
    }
}

public struct ChangeTierIntentModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let activationDate: Date
    public let tiers: [Tier]
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
    public let name: String
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
            return quotes.first?.basePremium.formattedAmountPerMonth
        } else {
            if let smallestPremium = quotes.sorted(by: { $0.basePremium.floatAmount < $1.basePremium.floatAmount })
                .first?
                .basePremium
                .formattedAmountPerMonth
            {
                return smallestPremium
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
    let basePremium: MonetaryAmount
    public let displayItems: [DisplayItem]
    public let productVariant: ProductVariant?
    let addons: [Addon]
    public init(
        id: String,
        quoteAmount: MonetaryAmount?,
        quotePercentage: Int?,
        subTitle: String?,
        basePremium: MonetaryAmount,
        displayItems: [DisplayItem],
        productVariant: ProductVariant?,
        addons: [Addon]
    ) {
        self.id = id
        deductableAmount = quoteAmount
        deductablePercentage = quotePercentage
        self.subTitle = subTitle
        self.basePremium = basePremium
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

        public init(
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

    var displayTitle: String {
        var displayTitle: String = (deductableAmount?.formattedAmount ?? "")

        if let deductiblePercentage = deductablePercentage {
            displayTitle += " + \(deductiblePercentage)%"
        }
        return displayTitle
    }
}

extension Quote: Equatable {
    public static func == (lhs: Quote, rhs: Quote) -> Bool {
        lhs.deductableAmount == rhs.deductableAmount && lhs.deductablePercentage == rhs.deductablePercentage
    }
}
