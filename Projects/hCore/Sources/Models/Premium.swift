import hGraphQL

public struct Premium: Equatable, Hashable, Codable, Sendable {
    public var gross: MonetaryAmount
    public var net: MonetaryAmount

    public init(
        gross: MonetaryAmount,
        net: MonetaryAmount
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

extension Premium {
    public static func + (lhs: Premium, rhs: Premium) -> Premium {
        Premium(gross: lhs.gross + rhs.gross, net: lhs.net + rhs.net)
    }

    public static func - (lhs: Premium, rhs: Premium) -> Premium {
        Premium(gross: lhs.gross - rhs.gross, net: lhs.net - rhs.net)
    }

    public static func zero(currency: String) -> Premium {
        .init(gross: MonetaryAmount.zero(currency: currency), net: MonetaryAmount.zero(currency: currency))
    }
}

extension [Premium] {
    public func sum() -> Premium {
        guard !self.isEmpty else { return Premium.zero(currency: "SEK") }
        let currency = self.first!.gross.currency
        return reduce(Premium.zero(currency: currency), +)
    }
}
