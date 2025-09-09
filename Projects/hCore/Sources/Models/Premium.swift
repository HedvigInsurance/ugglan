public struct Premium {
    public var net: MonetaryAmount?
    public var gross: MonetaryAmount?

    public init(
        net: MonetaryAmount?,
        gross: MonetaryAmount?
    ) {
        self.net = net
        self.gross = gross
    }
}
