import hGraphQL

public struct ItemCost: Equatable, Hashable, Codable, Sendable {
    public let premium: Premium
    public let discounts: [ItemDiscount]

    public init(premium: Premium, discounts: [ItemDiscount]) {
        self.premium = premium
        self.discounts = discounts
    }

    public init(fragment: OctopusGraphQL.ItemCostFragment) {
        self.premium = .init(
            gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
        )
        self.discounts = fragment.discounts.map { .init(fragment: $0.fragments.itemDiscountFragment) }
    }
}

public struct ItemDiscount: Equatable, Hashable, Codable, Sendable {
    public let campaignCode: String?
    public let displayName: String
    public let displayValue: String
    public let explanation: String?

    public init(campaignCode: String? = nil, displayName: String, displayValue: String, explanation: String? = nil) {
        self.campaignCode = campaignCode
        self.displayName = displayName
        self.displayValue = displayValue
        self.explanation = explanation
    }

    public init(fragment: OctopusGraphQL.ItemDiscountFragment) {
        self.campaignCode = fragment.campaignCode
        self.displayName = fragment.displayName
        self.displayValue = fragment.displayValue
        self.explanation = fragment.explanation
    }
}
