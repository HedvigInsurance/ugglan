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
        fragment: GiraffeGraphQL.MonetaryAmountFragmentGiraffe
    ) {
        amount = fragment.amount
        currency = fragment.currency
    }

    public init?(
        optionalFragment: GiraffeGraphQL.MonetaryAmountFragmentGiraffe?
    ) {
        guard let optionalFragment else { return nil }
        amount = optionalFragment.amount
        currency = optionalFragment.currency
    }

    public init(
        fragment: OctopusGraphQL.MoneyFragment
    ) {
        amount = String(fragment.amount)
        currency = fragment.currencyCode.rawValue
    }

    public var amount: String
    public var currency: String
}
