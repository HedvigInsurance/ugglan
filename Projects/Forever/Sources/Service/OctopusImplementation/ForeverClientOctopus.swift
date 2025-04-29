import Foundation
import hCore
import hGraphQL

public class ForeverClientOctopus: ForeverClient {
    @Inject var octopus: hOctopus
    public init() {}

    public func getMemberReferralInformation() async throws -> ForeverData {
        let query = OctopusGraphQL.MemberReferralInformationQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            .currentMember

        let referrals: [Referral] = data.referralInformation.referrals.map { referral in
            Referral(from: referral)
        }

        var referredBy: Referral? {
            if let referral = data.referralInformation.referredBy {
                return Referral(from: referral)
            }
            return nil
        }

        let foreverData = ForeverData(
            grossAmount: .init(fragment: data.insuranceCost.monthlyGross.fragments.moneyFragment),
            netAmount: .init(fragment: data.insuranceCost.monthlyNet.fragments.moneyFragment),
            otherDiscounts: .init(
                optionalFragment: data.referralInformation.referredBy?.activeDiscount?.fragments.moneyFragment
            ),
            discountCode: data.referralInformation.code,
            monthlyDiscount: .init(fragment: data.insuranceCost.monthlyDiscount.fragments.moneyFragment),
            referrals: referrals,
            referredBy: referredBy,
            monthlyDiscountPerReferral: .init(
                fragment: data.referralInformation.monthlyDiscountPerReferral.fragments.moneyFragment
            )
        )
        return foreverData
    }

    public func changeCode(code: String) async throws {
        let mutation = OctopusGraphQL.MemberReferralInformationCodeUpdateMutation(code: code)
        let response = try await octopus.client.perform(mutation: mutation)
        if let errorMessage = response.memberReferralInformationCodeUpdate.userError?.message {
            throw ForeverChangeCodeError.errorMessage(message: errorMessage)
        }
    }
}

extension Referral {
    fileprivate init(
        from data: OctopusGraphQL.MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.Referral
    ) {
        self.name = data.name
        if let activeDiscount = data.activeDiscount?.fragments.moneyFragment {
            self.activeDiscount = MonetaryAmount(fragment: activeDiscount)
        } else {
            activeDiscount = MonetaryAmount(amount: "", currency: "")
        }
        if data.status == .active {
            self.status = .active
        } else if data.status == .pending {
            self.status = .pending
        } else if data.status == .terminated {
            self.status = .terminated
        } else {
            self.status = .pending
        }
    }

    fileprivate init(
        from data: OctopusGraphQL.MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.ReferredBy
    ) {
        self.name = data.name
        if let activeDiscount = data.activeDiscount?.fragments.moneyFragment {
            self.activeDiscount = MonetaryAmount(fragment: activeDiscount)
        } else {
            activeDiscount = MonetaryAmount(amount: "", currency: "")
        }

        if data.status == .active {
            self.status = .active
        } else if data.status == .pending {
            self.status = .pending
        } else if data.status == .terminated {
            self.status = .terminated
        } else {
            self.status = .pending
        }
    }
}
