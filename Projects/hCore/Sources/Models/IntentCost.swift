public struct IntentCost: Codable, Equatable, Hashable, Sendable {
    public let totalCost: Premium
    public let quoteCosts: [QuoteCost]

    public init(totalCost: Premium, quoteCosts: [QuoteCost]) {
        self.totalCost = totalCost
        self.quoteCosts = quoteCosts
    }
}

public struct QuoteCost: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let cost: ItemCost

    public init(id: String, cost: ItemCost) {
        self.id = id
        self.cost = cost
    }
}
