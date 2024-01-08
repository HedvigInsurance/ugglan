import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public final class ForeverStore: LoadingStateStore<ForeverState, ForeverAction, ForeverLoadingType> {
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        switch action {
        case .fetch:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let query = OctopusGraphQL.MemberReferralInformationQuery()
                disposeBag += self.octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                    .onValue { data in
                        let grossAmount = data.currentMember.insuranceCost.monthlyGross
                        let grossAmountMonetary = MonetaryAmount(fragment: grossAmount.fragments.moneyFragment)

                        let netAmount = data.currentMember.insuranceCost.monthlyNet
                        let netAmountMonetary = MonetaryAmount(fragment: netAmount.fragments.moneyFragment)

                        let monthlyDiscount = data.currentMember.insuranceCost.monthlyDiscount
                        let monthlyDiscountAmountMonetary = MonetaryAmount(
                            fragment: monthlyDiscount.fragments.moneyFragment
                        )

                        let discountCode = data.currentMember.referralInformation.code
                        let monthlyDiscountExcludingReferrals = data.currentMember.referralInformation
                            .monthlyDiscountExcludingReferrals
                        let monthlyDiscountExcludingReferralsMonetary = MonetaryAmount(
                            fragment: monthlyDiscountExcludingReferrals.fragments.moneyFragment
                        )

                        let monthlyDiscountPerReferral = data.currentMember.referralInformation
                            .monthlyDiscountPerReferral
                        let monthlyDiscountPerReferralMonetary = MonetaryAmount(
                            fragment: monthlyDiscountPerReferral.fragments.moneyFragment
                        )

                        let referrals: [Referral] = data.currentMember.referralInformation.referrals.map { referral in
                            Referral(from: referral)
                        }

                        callback(
                            .value(
                                .setForeverData(
                                    data: ForeverData(
                                        grossAmount: grossAmountMonetary,
                                        netAmount: netAmountMonetary,
                                        otherDiscounts: monthlyDiscountExcludingReferralsMonetary,
                                        discountCode: discountCode,
                                        monthlyDiscount: monthlyDiscountAmountMonetary,
                                        referrals: referrals,
                                        monthlyDiscountPerReferral: monthlyDiscountPerReferralMonetary
                                    )
                                )
                            )
                        )

                    }
                    .onError({ error in
                        self.setError(L10n.General.errorBody, for: .fetchForeverData)
                    })
                return disposeBag
            }
        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: ForeverState, _ action: ForeverAction) -> ForeverState {
        var newState = state

        switch action {
        case let .setForeverData(data):
            newState.foreverData = data
        default:
            break
        }

        return newState
    }
}
