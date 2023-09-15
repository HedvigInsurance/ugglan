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
    case setNewForeverData(data: ForeverDataNew)
    case showInfoSheet(discount: String)
    case closeInfoSheet
    case showShareSheetOnly(code: String, discount: String)
}

public final class ForeverStore: StateStore<ForeverState, ForeverAction> {
    @Inject var giraffe: hGiraffe
    
    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        switch action {
        case .fetch:
            //            return giraffe.client.fetch(query: GiraffeGraphQL.ForeverQuery())
            return giraffe.client.fetch(query: OctopusGraphQL.MemberReferralInformationQuery())
                .valueThenEndSignal
                .map { data in
                    //                    let grossAmount = data.referralInformation.costReducedIndefiniteDiscount?.monthlyGross
                    let grossAmount = data.currentMember.insuranceCost.monthlyGross
                    let grossAmountMonetary = MonetaryAmount(
                        amount: grossAmount.fragments.monetaryAmountFragment?.amount ?? "",
                        currency: grossAmount.fragments.monetaryAmountFragment?.currency ?? ""
                    )
                    
                    //                    let netAmount = data.referralInformation.costReducedIndefiniteDiscount?.monthlyNet
                    //                    let netAmountMonetary = MonetaryAmount(
                    //                        amount: netAmount?.amount ?? "",
                    //                        currency: netAmount?.currency ?? ""
                    //                    )
                    let netAmount = data.currentMember.insuranceCost.monthlyNet
                    let netAmountMonetary = MonetaryAmount(
                        amount: netAmount.fragments.monetaryAmountFragment?.amount ?? "",
                        currency: netAmount.fragments.monetaryAmountFragment?.amount ?? ""
                    )
                    let monthlyDiscount = data.currentMember.insuranceCost.monthlyDiscount
                    let monthlyDiscountAmountMonetary = MonetaryAmount(
                        amount: monthlyDiscount.fragments.monetaryAmountFragment?.amount ?? "",
                        currency: monthlyDiscount.fragments.monetaryAmountFragment?.amount ?? ""
                    )
                    
                    let discountCode = data.currentMember.referralInformation.code
                    let monthlyDiscountExcludingReferrals = data.currentMember.referralInformation.monthlyDiscountExcludingReferrals
                    let monthlyDiscountExcludingReferralsMonetary = MonetaryAmount(
                        amount: monthlyDiscountExcludingReferrals.fragments.monetaryAmountFragment?.amount ?? "",
                        currency: monthlyDiscountExcludingReferrals.fragments.monetaryAmountFragment?.amount ?? ""
                    )
                    let monthlyDiscountPerReferral = data.currentMember.referralInformation.monthlyDiscountPerReferral
                    let monthlyDiscountPerReferralMonetary = MonetaryAmount(
                        amount: monthlyDiscountPerReferral.fragments.monetaryAmountFragment?.amount ?? "",
                        currency: monthlyDiscountPerReferral.fragments.monetaryAmountFragment?.amount ?? ""
                    )
                    
                    //                    let potentialDiscountAmount = data.referralInformation.campaign.incentive?
                    //                        .asMonthlyCostDeduction?
                    //                        .amount
                    //                    let potentialDiscountAmountMonetary = MonetaryAmount(
                    //                        amount: potentialDiscountAmount?.amount ?? "",
                    //                        currency: potentialDiscountAmount?.currency ?? ""
                    //                    )
                    
                    //                    let discountCode = data.referralInformation.campaign.code
                    
                    //                    var invitations = data.currentMember.referralInformation.referrals
                    
                    //                    var invitations = data.referralInformation.invitations
                    //                        .map { invitation -> ForeverInvitation? in
                    //                            if let inProgress = invitation.asInProgressReferral {
                    //                                return .init(
                    //                                    name: inProgress.name ?? "",
                    //                                    state: .pending,
                    //                                    discount: nil,
                    //                                    invitedByOther: false
                    //                                )
                    //                            } else if let active = invitation.asActiveReferral {
                    //                                let discount = active.discount
                    //                                return .init(
                    //                                    name: active.name ?? "",
                    //                                    state: .active,
                    //                                    discount: MonetaryAmount(
                    //                                        amount: discount.amount,
                    //                                        currency: discount.currency
                    //                                    ),
                    //                                    invitedByOther: false
                    //                                )
                    //                            } else if let terminated = invitation.asTerminatedReferral {
                    //                                return .init(
                    //                                    name: terminated.name ?? "",
                    //                                    state: .terminated,
                    //                                    discount: nil,
                    //                                    invitedByOther: false
                    //                                )
                    //                            }
                    //
                    //                            return nil
                    //                        }
                    //                        .compactMap { $0 }
                    
                    //                    let referredBy = data.referralInformation.referredBy
                    
                    let referrals: [Referral] = data.currentMember.referralInformation.referrals.map { referral in
                        let status = data.currentMember.referralInformation.referrals.first?.status
                        if status == .pending {
                            return Referral(
                                name: referral.name,
                                activeDiscounts: MonetaryAmount(
                                    amount: referral.activeDiscount?.fragments.monetaryAmountFragment?.amount ?? "",
                                    currency: referral.activeDiscount?.fragments.monetaryAmountFragment?.currency ?? ""),
                                status: .pending
                            )
                        } else if status == .active {
                            return Referral(
                                name: referral.name,
                                activeDiscounts: MonetaryAmount(
                                    amount: referral.activeDiscount?.fragments.monetaryAmountFragment?.amount ?? "",
                                    currency: referral.activeDiscount?.fragments.monetaryAmountFragment?.currency ?? ""),
                                status: .active
                            )
                        } else if status == .terminated {
                            return Referral(
                                name: referral.name,
                                activeDiscounts: MonetaryAmount(
                                    amount: referral.activeDiscount?.fragments.monetaryAmountFragment?.amount ?? "",
                                    currency: referral.activeDiscount?.fragments.monetaryAmountFragment?.currency ?? ""),
                                status: .pending
                            )
                        } else {
                            return Referral(
                                name: referral.name,
                                activeDiscounts: MonetaryAmount(
                                    amount: referral.activeDiscount?.fragments.monetaryAmountFragment?.amount ?? "",
                                    currency: referral.activeDiscount?.fragments.monetaryAmountFragment?.currency ?? ""),
                                status: .pending
                            )
                        }
                    }
                    
                    //                    if let inProgress = referredBy?.asInProgressReferral {
                    //                        invitations.insert(
                    //                            .init(
                    //                                name: inProgress.name ?? "",
                    //                                state: .pending,
                    //                                discount: nil,
                    //                                invitedByOther: true
                    //                            ),
                    //                            at: 0
                    //                        )
                    //                    } else if let active = referredBy?.asActiveReferral {
                    //                        let discount = active.discount
                    //                        invitations.insert(
                    //                            .init(
                    //                                name: active.name ?? "",
                    //                                state: .active,
                    //                                discount: MonetaryAmount(
                    //                                    amount: discount.amount,
                    //                                    currency: discount.currency
                    //                                ),
                    //                                invitedByOther: true
                    //                            ),
                    //                            at: 0
                    //                        )
                    //                    } else if let terminated = referredBy?.asTerminatedReferral {
                    //                        invitations.insert(
                    //                            .init(
                    //                                name: terminated.name ?? "",
                    //                                state: .terminated,
                    //                                discount: nil,
                    //                                invitedByOther: true
                    //                            ),
                    //                            at: 0
                    //                        )
                    //                    }
                    
                    //                    let otherDiscounts: MonetaryAmount? = {
                    //
                    //                        let referalDiscounts = invitations.compactMap({ $0.discount?.floatAmount })
                    //                            .reduce(0) { $0 + $1 }
                    ////                        let gross = grossAmountMonetary.floatAmount
                    //                        let gross = grossAmount.amount
                    ////                        let net = netAmountMonetary.floatAmount
                    //                        let net = netAmount.amount
                    //                        if gross - referalDiscounts > net {
                    ////                            return .init(amount: gross - net - referalDiscounts, currency: grossAmountMonetary.currency)
                    //                            return .init(amount: gross - net - referalDiscounts, currency: grossAmount.currency)
                    //                        }
                    //                        return nil
                    //                    }()
                    
                    //                    return .setForeverData(
                    //                        data: .init(
                    //                            grossAmount: grossAmountMonetary,
                    //                            netAmount: netAmountMonetary,
                    //                            potentialDiscountAmount: potentialDiscountAmountMonetary,
                    //                            otherDiscounts: otherDiscounts,
                    //                            discountCode: discountCode,
                    //                            invitations: invitations
                    //                        )
                    //                    )
                    return .setNewForeverData(
                        data: ForeverDataNew(
                            grossAmount: grossAmountMonetary,
                            netAmount: netAmountMonetary,
                            monthlyDiscount: monthlyDiscountAmountMonetary,
                            referrals: referrals,
                            monthlyDiscountExcludingReferrals: monthlyDiscountExcludingReferralsMonetary,
                            monthlyDiscountPerReferral: monthlyDiscountPerReferralMonetary,
                            discountCode: discountCode)
                    )
                    //                    return .setNewForeverData(
                    //                        data: .init(
                    //                            grossAmount: grossAmount,
                    //                            netAmount: netAmount,
                    ////                            monthlyDiscount: monthlyDiscount,
                    ////                            potentialDiscountAmount: potentialDiscountAmountMonetary,
                    ////                            otherDiscounts: otherDiscounts,
                    //                            discountCode: discountCode
                    ////                            invitations: invitations
                    //                        )
                    //                    )
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
