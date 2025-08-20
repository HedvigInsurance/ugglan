public struct IntentCost: Sendable {
    public let totalGross: MonetaryAmount
    public let totalNet: MonetaryAmount

    public init(totalGross: MonetaryAmount, totalNet: MonetaryAmount) {
        self.totalGross = totalGross
        self.totalNet = totalNet
    }
}
