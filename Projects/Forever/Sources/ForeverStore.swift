import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct ForeverState: StateProtocol {
    public var hasSeenFebruaryCampaign: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenFebruaryCampaign, forKey: Self.hasSeenFebruaryCampaignKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate static var hasSeenFebruaryCampaignKey: String {
        "ForeverFebruaryCampaign-hasBeenSeen"
    }
    
    public init() {
        self.hasSeenFebruaryCampaign = false
    }
    
    public var foreverData: ForeverData? = nil
}

public indirect enum ForeverAction: ActionProtocol {
    case hasSeenFebruaryCampaign(value: Bool)
    case showChangeCodeDetail
    case showChangeCodeSuccess
    case dismissChangeCodeDetail
    case fetch
    case setForeverData(data: ForeverData)
    case showInfoSheet(discount: String)
    case closeInfoSheet
    case showShareSheetOnly(code: String, discount: String)
}

public final class ForeverStore: StateStore<ForeverState, ForeverAction> {
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
                    callback(.value(.setForeverData(
                        data: ForeverData(
                            grossAmount: grossAmountMonetary,
                            netAmount: netAmountMonetary,
                            otherDiscounts: monthlyDiscountExcludingReferralsMonetary,
                            discountCode: discountCode,
                            monthlyDiscount: monthlyDiscountAmountMonetary,
                            referrals: referrals,
                            monthlyDiscountPerReferral: monthlyDiscountPerReferralMonetary
                        ))))

                }
                .onError({ error in
                    /* TODO */
//                    switch error {
//                    case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, let rawData):
//                        print(String(data: rawData!, encoding: .utf8))
//                default:
//                    break
//                    }
//                    print(error)
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
        case let .hasSeenFebruaryCampaign(hasSeenFebruaryCampaign):
            newState.hasSeenFebruaryCampaign = hasSeenFebruaryCampaign
        case let .setForeverData(data):
            newState.foreverData = data
        default:
            break
        }
        
        return newState
    }
}
