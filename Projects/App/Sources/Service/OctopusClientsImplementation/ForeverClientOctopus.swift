import Forever
import Foundation
import hCore
import hGraphQL

class ForeverClientOctopus: ForeverClient {
    @Inject var octopus: hOctopus

    func getMemberReferralInformation() async throws -> ForeverData {
        let query = OctopusGraphQL.MemberReferralInformationQuery()
        let data = try await octopus.client.fetch(query: query)
            .currentMember

        let referrals: [Referral] = data.referralInformation.referrals.map { referral in
            Referral(from: referral.fragments.memberReferralFragment)
        }

        var referredBy: Referral? {
            if let referral = data.referralInformation.referredBy {
                return Referral(from: referral.fragments.memberReferralFragment)
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

    func changeCode(code: String) async throws {
        let mutation = OctopusGraphQL.MemberReferralInformationCodeUpdateMutation(code: code)
        let response = try await octopus.client.mutation(mutation: mutation)
        if let errorMessage = response?.memberReferralInformationCodeUpdate.userError?.message {
            throw ForeverChangeCodeError.errorMessage(message: errorMessage)
        }
    }
}

extension Referral {
    fileprivate init(from data: OctopusGraphQL.MemberReferralFragment) {
        let activeDiscount = {
            if let activeDiscount = data.activeDiscount?.fragments.moneyFragment {
                return MonetaryAmount(fragment: activeDiscount)
            } else {
                return MonetaryAmount(amount: "", currency: "")
            }
        }()

        let status: Referral.State = {
            if data.status == .active {
                return .active
            } else if data.status == .pending {
                return .pending
            } else if data.status == .terminated {
                return .terminated
            } else {
                return .pending
            }
        }()
        self.init(
            name: data.name,
            activeDiscount: activeDiscount,
            status: status
        )
    }
}
