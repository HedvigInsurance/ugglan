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
    public var dataSignal: ReadSignal<ForeverData?> {
        client.watch(query: ForeverQuery()).map { result -> ForeverData in
            let grossAmount = result.data?.referralInformation.costReducedIndefiniteDiscount?.monthlyGross
            let grossAmountMonetary = MonetaryAmount(amount: grossAmount?.amount ?? "", currency: grossAmount?.currency ?? "")
            
            let netAmount = result.data?.referralInformation.costReducedIndefiniteDiscount?.monthlyNet
            let netAmountMonetary = MonetaryAmount(amount: netAmount?.amount ?? "", currency: netAmount?.currency ?? "")
            
            let potentialDiscountAmount = result.data?.referralInformation.campaign.incentive?.asMonthlyCostDeduction?.amount
            let potentialDiscountAmountMonetary = MonetaryAmount(amount: potentialDiscountAmount?.amount ?? "", currency: potentialDiscountAmount?.currency ?? "")
            
            let discountCode = result.data?.referralInformation.campaign.code ?? ""
            
            return .init(
                grossAmount: grossAmountMonetary,
                netAmount: netAmountMonetary,
                potentialDiscountAmount: potentialDiscountAmountMonetary,
                discountCode: discountCode,
                invitations: []
            )
        }.readable(initial: nil)
    }
    
    public func refetch() {
        client.fetch(query: ForeverQuery(), cachePolicy: .fetchIgnoringCacheData).onValue { _ in }
    }
    
    public init() {}
    
    @Inject var client: ApolloClient
}
