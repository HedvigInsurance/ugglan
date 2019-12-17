//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Apollo
import Firebase
import Flow
import Foundation
import FBSDKCoreKit

struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient
    
    func logEcommercePurchase() {
        let bag = DisposeBag()
        bag += client.fetch(query: InsurancePriceQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.cost?.fragments.costFragment.monthlyGross }
            .onValue { monthlyGross in
                bag.dispose()
                
                AppEvents.logPurchase(
                    Double(monthlyGross.amount) ?? 0,
                    currency: monthlyGross.currency
                )
                
                Analytics.logEvent("ecommerce_purchase", parameters: [
                    "transaction_id": UUID().uuidString,
                    "value": Double(monthlyGross.amount) ?? 0,
                    "currency": monthlyGross.currency,
                ])
            }
    }
}
