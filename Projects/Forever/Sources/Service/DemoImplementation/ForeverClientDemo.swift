public class ForeverClientDemo: ForeverClient {
    var code: String = "CODE"
    public init() {}

    public func getMemberReferralInformation() async throws -> ForeverData {
        ForeverData(
            grossAmount: .init(amount: "200", currency: "SEK"),
            netAmount: .init(amount: "200", currency: "SEK"),
            otherDiscounts: .init(amount: "0", currency: "SEK"),
            discountCode: code,
            monthlyDiscount: .init(amount: "10", currency: "SEK"),
            referrals: [],
            referredBy: .init(name: "", activeDiscount: nil, status: .active),
            monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
        )
    }

    public func changeCode(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        self.code = code
    }
}
