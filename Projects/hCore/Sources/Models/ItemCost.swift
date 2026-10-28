public struct ItemCost: Equatable, Hashable, Codable, Sendable {
    public let premium: Premium
    public let discounts: [ItemDiscount]

    public init(premium: Premium, discounts: [ItemDiscount]) {
        self.premium = premium
        self.discounts = discounts
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
}
