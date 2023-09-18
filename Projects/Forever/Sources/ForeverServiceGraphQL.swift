import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

public class ForeverServiceGraphQL: ForeverService {
    public func changeDiscountCode(_ value: String) -> Signal<Either<Void, String>> {
        octopus.client.perform(mutation: OctopusGraphQL.MemberReferralInformationCodeUpdateMutation(code: value))
            .valueSignal
            .map { data -> Either<Void, String> in
                let userErrorMessage = data.memberReferralInformationCodeUpdate.userError
                if let message = userErrorMessage?.message {
                    return .right(message)
                } else {
                    self.octopus.store.withinReadWriteTransaction(
                        { transaction in
                            try transaction.update(query: OctopusGraphQL.MemberReferralInformationQuery()) {
                                (data: inout OctopusGraphQL.MemberReferralInformationQuery.Data) in
                                data.currentMember.referralInformation.code = value
                            }
                        },
                        completion: nil
                    )
                    return .left(())
                }
            }
            .plain()
    }
    
    public var dataSignal: ReadSignal<ForeverData?> {
        octopus.client.watch(query: OctopusGraphQL.MemberReferralInformationQuery())
            .map { data -> ForeverData in
                let grossAmount = data.currentMember.insuranceCost.monthlyGross
                let grossAmountMonetary = MonetaryAmount(
                    amount: grossAmount.fragments.monetaryAmountFragment.amount.description,
                    currency: grossAmount.fragments.monetaryAmountFragment.currencyCode.rawValue
                )
                
                let netAmount = data.currentMember.insuranceCost.monthlyNet
                let netAmountMonetary = MonetaryAmount(
                    amount: netAmount.fragments.monetaryAmountFragment.amount.description,
                    currency: netAmount.fragments.monetaryAmountFragment.currencyCode.rawValue
                )
                let monthlyDiscount = data.currentMember.insuranceCost.monthlyDiscount
                let monthlyDiscountAmountMonetary = MonetaryAmount(
                    amount: monthlyDiscount.fragments.monetaryAmountFragment.amount.description,
                    currency: monthlyDiscount.fragments.monetaryAmountFragment.currencyCode.rawValue
                )
                
                let discountCode = data.currentMember.referralInformation.code
                let monthlyDiscountExcludingReferrals = data.currentMember.referralInformation.monthlyDiscountExcludingReferrals
                let monthlyDiscountExcludingReferralsMonetary = MonetaryAmount(
                    amount: monthlyDiscountExcludingReferrals.fragments.monetaryAmountFragment.amount.description,
                    currency: monthlyDiscountExcludingReferrals.fragments.monetaryAmountFragment.currencyCode.rawValue
                )
                let monthlyDiscountPerReferral = data.currentMember.referralInformation.monthlyDiscountPerReferral
                let monthlyDiscountPerReferralMonetary = MonetaryAmount(
                    amount: monthlyDiscountPerReferral.fragments.monetaryAmountFragment.amount.description,
                    currency: monthlyDiscountPerReferral.fragments.monetaryAmountFragment.currencyCode.rawValue
                )
                
                let referrals: [Referral] = data.currentMember.referralInformation.referrals.map { referral in
                    let status = data.currentMember.referralInformation.referrals.first?.status
                    if status == .pending {
                        return Referral(
                            name: referral.name,
                            activeDiscount: MonetaryAmount(
                                amount: referral.activeDiscount?.fragments.monetaryAmountFragment.amount.description ?? "",
                                currency: referral.activeDiscount?.fragments.monetaryAmountFragment.currencyCode.rawValue ?? ""),
                            status: .pending
                        )
                    } else if status == .active {
                        return Referral(
                            name: referral.name,
                            activeDiscount: MonetaryAmount(
                                amount: referral.activeDiscount?.fragments.monetaryAmountFragment.amount.description ?? "",
                                currency: referral.activeDiscount?.fragments.monetaryAmountFragment.currencyCode.rawValue ?? ""),
                            status: .active
                        )
                    } else if status == .terminated {
                        return Referral(
                            name: referral.name,
                            activeDiscount: MonetaryAmount(
                                amount: referral.activeDiscount?.fragments.monetaryAmountFragment.amount.description ?? "",
                                currency: referral.activeDiscount?.fragments.monetaryAmountFragment.currencyCode.rawValue ?? ""),
                            status: .pending
                        )
                    } else {
                        return Referral(
                            name: referral.name,
                            activeDiscount: MonetaryAmount(
                                amount: referral.activeDiscount?.fragments.monetaryAmountFragment.amount.description ?? "",
                                currency: referral.activeDiscount?.fragments.monetaryAmountFragment.currencyCode.rawValue ?? ""),
                            status: .pending
                        )
                    }
                }
                return .init(
                    grossAmount: grossAmountMonetary,
                    netAmount: netAmountMonetary,
                    otherDiscounts: monthlyDiscountExcludingReferralsMonetary,
                    discountCode: discountCode,
                    monthlyDiscount: monthlyDiscountAmountMonetary,
                    referrals: referrals,
                    monthlyDiscountPerReferral: monthlyDiscountPerReferralMonetary
                )
            }
            .readable(initial: nil)
    }
    
    public func refetch() {
        octopus.client.fetch(query: OctopusGraphQL.MemberReferralInformationQuery(), cachePolicy: .fetchIgnoringCacheData).sink()
    }
    
    public init() {}
    
    @Inject var octopus: hOctopus
}
