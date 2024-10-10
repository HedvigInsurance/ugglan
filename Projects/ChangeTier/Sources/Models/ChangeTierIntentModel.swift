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
}

public struct Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    let name: String
    let level: Int
    let deductibles: [Deductible]
    let premium: MonetaryAmount
    let displayItems: [TierDisplayItem]
    let exposureName: String?
    let productVariant: ProductVariant?
    let FAQs: [FAQ]?

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
    public var id: String = UUID().uuidString

    let deductibleAmount: MonetaryAmount?
    let deductiblePercentage: Int?
    let subTitle: String?
    let premium: MonetaryAmount?

    public init(
        deductibleAmount: MonetaryAmount?,
        deductiblePercentage: Int?,
        subTitle: String?,
        premium: MonetaryAmount?
    ) {
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
