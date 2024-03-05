public class ForeverServiceDemo: ForeverService {

    public init() {}

    public func getMemberReferralInformation() async throws -> ForeverData {
        return ForeverData(
            grossAmount: .init(amount: "200", currency: "SEK"),
            netAmount: .init(amount: "200", currency: "SEK"),
            otherDiscounts: .init(amount: "0", currency: "SEK"),
            discountCode: "CODE",
            monthlyDiscount: .init(amount: "10", currency: "SEK"),
            referrals: [],
            monthlyDiscountPerReferral: .init(amount: "10", currency: "SEK")
        )

    }
}
