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
            return quotes.first?.newTotalCost.net.formattedAmountPerMonth
        } else {
            if let smallestPremium = quotes.map({ $0.newTotalCost.net }).sorted(by: { $0.amount < $1.amount })
                .first?
                .formattedAmount
            {
                return L10n.tierFlowPriceLabelWithoutCurrency(smallestPremium)
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
    public let currentTotalCost: TotalCost
    let newTotalCost: TotalCost
    public let displayItems: [DisplayItem]
    public let productVariant: ProductVariant?
    let addons: [Addon]
    let costBreakdown: [DisplayItem]
    public init(
        id: String,
        quoteAmount: MonetaryAmount?,
        quotePercentage: Int?,
        subTitle: String?,
        currentTotalCost: TotalCost,
        newTotalCost: TotalCost,
        displayItems: [DisplayItem],
        productVariant: ProductVariant?,
        addons: [Addon],
        costBreakdown: [DisplayItem]
    ) {
        self.id = id
        deductableAmount = quoteAmount
        deductablePercentage = quotePercentage
        self.subTitle = subTitle
        self.currentTotalCost = currentTotalCost
        self.newTotalCost = newTotalCost
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.addons = addons
        self.costBreakdown = costBreakdown
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
        let addonVariant: AddonVariant
        public init(
            addonVariant: AddonVariant,
        ) {
            self.addonVariant = addonVariant
        }
    }

    public struct TotalCost: Codable, Equatable, Hashable, Sendable {
        let gross: MonetaryAmount
        let net: MonetaryAmount

        public init(gross: MonetaryAmount, net: MonetaryAmount) {
            self.gross = gross
            self.net = net
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
