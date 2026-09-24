public struct PaymentNoticeData: Codable, Equatable, Sendable, Hashable {
    public let showPreChargeNotice: Bool
    public let showRetryChargeNotice: Bool

    public init(
        showPreChargeNotice: Bool,
        showRetryChargeNotice: Bool
    ) {
        self.showPreChargeNotice = showPreChargeNotice
        self.showRetryChargeNotice = showRetryChargeNotice
    }

    public var hasNotice: Bool {
        showPreChargeNotice || showRetryChargeNotice
    }
}
