import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ChangeTierIntentModel: Codable, Equatable, Hashable {
    let id: String
    let activationDate: Date
    let tiers: [Tier]
    let currentPremium: MonetaryAmount
}

public struct Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    let name: String
    let level: Int
    let deductibles: [Deductible]
    let premium: MonetaryAmount
    let displayItems: [TierDisplayItem]
    let exposureName: String?
    let productVariant: ProductVariant

    public struct TierDisplayItem: Codable, Equatable, Hashable {
        let title: String
        let subTitle: String?
        let value: String
    }
}

public struct Deductible: Codable, Equatable, Hashable, Identifiable {
    public let id: String

    let deductibleAmount: MonetaryAmount?
    let deductiblePercentage: Int?
}
