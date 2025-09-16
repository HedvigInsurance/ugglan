public struct Premium: Sendable {
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
