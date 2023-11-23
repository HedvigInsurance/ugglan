public struct MonetaryAmount: Equatable, Hashable, Codable {
    public init(
        amount: String,
        currency: String
    ) {
        self.amount = amount
        self.currency = currency
    }

    public init(
        amount: Float,
        currency: String
    ) {
        self.amount = String(amount)
        self.currency = currency
    }

    public init(
        fragment: OctopusGraphQL.MoneyFragment
    ) {
        amount = String(fragment.amount)
        currency = fragment.currencyCode.rawValue
    }

    public init?(
        optionalFragment: OctopusGraphQL.MoneyFragment?
    ) {
        guard let optionalFragment else { return nil }
        amount = String(optionalFragment.amount)
        currency = optionalFragment.currencyCode.rawValue
    }

    public var amount: String
    public var currency: String
}
