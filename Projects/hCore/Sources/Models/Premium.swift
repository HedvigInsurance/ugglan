import hGraphQL

public struct Premium: Equatable, Hashable, Sendable {
    public var gross: MonetaryAmount?
    public var net: MonetaryAmount?

    public init(
        gross: MonetaryAmount?,
        net: MonetaryAmount?
    ) {
        self.gross = gross
        self.net = net
    }
}

extension Premium {
    public init(
        fragment: OctopusGraphQL.ItemCostFragment
    ) {
        self.init(
            gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment)
        )
    }
}
