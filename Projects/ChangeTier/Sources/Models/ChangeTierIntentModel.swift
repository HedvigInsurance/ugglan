import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ChangeTierIntentModel: Codable, Equatable, Hashable {
    let activationDate: Date
    let tiers: [Tier]
    let currentPremium: MonetaryAmount
    let currentTier: Tier?
    let currentDeductible: Deductible?
    let canEditTier: Bool

    public init(
        activationDate: Date,
        tiers: [Tier],
        currentPremium: MonetaryAmount,
        currentTier: Tier?,
        currentDeductible: Deductible?,
        canEditTier: Bool
    ) {
        self.activationDate = activationDate
        self.tiers = tiers
        self.currentPremium = currentPremium
        self.currentTier = currentTier
        self.currentDeductible = currentDeductible
        self.canEditTier = canEditTier
    }
}

public struct Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    let name: String
    let level: Int
    public let deductibles: [Deductible]
    let premium: MonetaryAmount
    let displayItems: [TierDisplayItem]
    let exposureName: String?
    let productVariant: ProductVariant?
    let FAQs: [FAQ]

    public init(
        id: String,
        name: String,
        level: Int,
        deductibles: [Deductible],
        premium: MonetaryAmount,
        displayItems: [TierDisplayItem],
        exposureName: String?,
        productVariant: ProductVariant?,
        FAQs: [FAQ]
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.deductibles = deductibles
        self.premium = premium
        self.displayItems = displayItems
        self.exposureName = exposureName
        self.productVariant = productVariant
        self.FAQs = FAQs
    }

    public struct TierDisplayItem: Codable, Equatable, Hashable {
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

public struct Deductible: Codable, Hashable, Identifiable {
    public var id: String

    let deductibleAmount: MonetaryAmount?
    let deductiblePercentage: Int?
    let subTitle: String?
    let premium: MonetaryAmount?

    public init(
        id: String,
        deductibleAmount: MonetaryAmount?,
        deductiblePercentage: Int?,
        subTitle: String?,
        premium: MonetaryAmount?
    ) {
        self.id = id
        self.deductibleAmount = deductibleAmount
        self.deductiblePercentage = deductiblePercentage
        self.subTitle = subTitle
        self.premium = premium
    }
}

extension Deductible: Equatable {
    static public func == (lhs: Deductible, rhs: Deductible) -> Bool {
        return lhs.deductibleAmount == rhs.deductibleAmount && lhs.deductiblePercentage == rhs.deductiblePercentage
    }
}
