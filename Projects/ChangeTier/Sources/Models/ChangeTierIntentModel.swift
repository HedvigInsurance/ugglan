import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ChangeTierIntentModel: Codable, Equatable, Hashable {
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

public struct Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    let name: String
    let level: Int
    public let quotes: [Quote]
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

    func getPremium() -> MonetaryAmount? {
        if quotes.count == 1 {
            return quotes.first?.premium
        }
        return nil
    }
}

public struct Quote: Codable, Hashable, Identifiable {
    public var id: String
    let quoteAmount: MonetaryAmount?
    let quotePercentage: Int?
    let subTitle: String?
    let premium: MonetaryAmount

    let displayItems: [DisplayItem]
    public let productVariant: ProductVariant?

    public init(
        id: String,
        quoteAmount: MonetaryAmount?,
        quotePercentage: Int?,
        subTitle: String?,
        premium: MonetaryAmount,
        displayItems: [DisplayItem],
        productVariant: ProductVariant?
    ) {
        self.id = id
        self.quoteAmount = quoteAmount
        self.quotePercentage = quotePercentage
        self.subTitle = subTitle
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
    }

    public struct DisplayItem: Codable, Equatable, Hashable {
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
}

extension Quote: Equatable {
    static public func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.quoteAmount == rhs.quoteAmount && lhs.quotePercentage == rhs.quotePercentage
    }
}
