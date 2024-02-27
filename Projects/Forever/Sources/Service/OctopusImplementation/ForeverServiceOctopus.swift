import Foundation
import hCore
import hGraphQL

public class ForeverServiceOctopus: ForeverService {
    @Inject var octopus: hOctopus
    public init() {}

    public func getMemberReferralInformation() async throws -> ForeverData {
        let query = OctopusGraphQL.MemberReferralInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            .currentMember

        let referrals: [Referral] = data.referralInformation.referrals.map { referral in
            Referral(from: referral)
        }

        let foreverData = ForeverData(
            grossAmount: .init(fragment: data.insuranceCost.monthlyGross.fragments.moneyFragment),
            netAmount: .init(fragment: data.insuranceCost.monthlyNet.fragments.moneyFragment),
            otherDiscounts: .init(
                fragment: data.referralInformation.monthlyDiscountExcludingReferrals.fragments.moneyFragment
            ),
            discountCode: data.referralInformation.code,
            monthlyDiscount: .init(fragment: data.insuranceCost.monthlyDiscount.fragments.moneyFragment),
            referrals: referrals,
            monthlyDiscountPerReferral: .init(
                fragment: data.referralInformation.monthlyDiscountPerReferral.fragments.moneyFragment
            )
        )
        return foreverData
    }
}
