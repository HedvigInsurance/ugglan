//
//  ForeverServiceGraphql.swift
//  Forever
//
//  Created by sam on 23.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Apollo
import hCore
import Flow

public class ForeverServiceGraphQL: ForeverService {
    public func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>> {
        client.perform(mutation: ForeverUpdateDiscountCodeMutation(code: value)).valueSignal.map { result in
            let updateReferralCampaignCode = result.data?.updateReferralCampaignCode
            
            if updateReferralCampaignCode?.asCodeAlreadyTaken != nil {
                return .right(ForeverChangeCodeError.nonUnique)
            } else if updateReferralCampaignCode?.asCodeTooLong != nil {
                return .right(ForeverChangeCodeError.tooLong)
            } else if updateReferralCampaignCode?.asCodeTooShort != nil {
                return .right(ForeverChangeCodeError.tooShort)
            } else if let maximumUpdates = updateReferralCampaignCode?.asExceededMaximumUpdates {
                return .right(ForeverChangeCodeError.exceededMaximumUpdates(amount: maximumUpdates.maximumNumberOfUpdates))
            } else if updateReferralCampaignCode?.asSuccessfullyUpdatedCode != nil {
                self.store.withinReadWriteTransaction({ transaction in
                    try transaction.update(query: ForeverQuery()) { (data: inout ForeverQuery.Data) in
                        data.referralInformation.campaign.code = value
                    }
                })
                
                return .left(())
            }
            
            return .right(ForeverChangeCodeError.unknown)
        }.plain()
    }
    
    public var dataSignal: ReadSignal<ForeverData?> {
        client.watch(query: ForeverQuery()).map { result -> ForeverData in
            let grossAmount = result.data?.referralInformation.costReducedIndefiniteDiscount?.monthlyGross
            let grossAmountMonetary = MonetaryAmount(amount: grossAmount?.amount ?? "", currency: grossAmount?.currency ?? "")
            
            let netAmount = result.data?.referralInformation.costReducedIndefiniteDiscount?.monthlyNet
            let netAmountMonetary = MonetaryAmount(amount: netAmount?.amount ?? "", currency: netAmount?.currency ?? "")
            
            let potentialDiscountAmount = result.data?.referralInformation.campaign.incentive?.asMonthlyCostDeduction?.amount
            let potentialDiscountAmountMonetary = MonetaryAmount(amount: potentialDiscountAmount?.amount ?? "", currency: potentialDiscountAmount?.currency ?? "")
            
            let discountCode = result.data?.referralInformation.campaign.code ?? ""
            
            var invitations = result.data?.referralInformation.invitations.map { invitation -> ForeverInvitation? in
                if let inProgress = invitation.asInProgressReferral {
                    return .init(name: inProgress.name ?? "", state: .pending, discount: nil, invitedByOther: false)
                } else if let active = invitation.asActiveReferral {
                    let discount = active.discount
                    return .init(
                        name: active.name ?? "",
                        state: .active,
                        discount: MonetaryAmount(amount: discount.amount, currency: discount.currency),
                        invitedByOther: false
                    )
                } else if let terminated = invitation.asTerminatedReferral {
                    return .init(
                        name: terminated.name ?? "",
                        state: .terminated,
                        discount: nil,
                        invitedByOther: false
                    )
                }
                
                return nil
            }.compactMap { $0 }
            
            let referredBy = result.data?.referralInformation.referredBy
            
            if let inProgress = referredBy?.asInProgressReferral {
                invitations?.insert(.init(
                    name: inProgress.name ?? "",
                    state: .pending,
                    discount: nil,
                    invitedByOther: true
                ), at: 0)
            } else if let active = referredBy?.asActiveReferral {
                let discount = active.discount
                invitations?.insert(.init(
                    name: active.name ?? "",
                    state: .active,
                    discount: MonetaryAmount(amount: discount.amount, currency: discount.currency),
                    invitedByOther: true
                ), at: 0)
            } else if let terminated = referredBy?.asTerminatedReferral {
                invitations?.insert(.init(
                    name: terminated.name ?? "",
                    state: .terminated,
                    discount: nil,
                    invitedByOther: true
                ), at: 0)
            }
            
            return .init(
                grossAmount: grossAmountMonetary,
                netAmount: netAmountMonetary,
                potentialDiscountAmount: potentialDiscountAmountMonetary,
                discountCode: discountCode,
                invitations: invitations ?? []
            )
        }.readable(initial: nil)
    }
    
    public func refetch() {
        client.fetch(query: ForeverQuery(), cachePolicy: .fetchIgnoringCacheData).onValue { _ in }
    }
    
    public init() {}
    
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
}
