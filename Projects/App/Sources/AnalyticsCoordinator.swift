//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Apollo
import Flow
import Foundation
import Firebase

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient
    @Inject private var remoteConfig: RemoteConfigContainer
    
    public init() {
        
    }

    func setUserId() {
        client.fetch(
            query: MemberIdQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        ).map { $0.data?.member.id }.onValue { id in
            guard let id = id else {
                return
            }

            Analytics.setUserID(id)
            self.remoteConfig.fetch(true)
        }
    }

    func logAddPaymentInfo() {
    }

    func logAddToCart() {
        let bag = DisposeBag()
        bag += client.fetch(query: InsurancePriceQuery())
            .valueSignal
            .compactMap { $0.data?.insuranceCost?.fragments.costFragment.monthlyGross }
            .onValue { monthlyGross in
                bag.dispose()
            }
    }

    func logEcommercePurchase() {
        let bag = DisposeBag()
        bag += client.fetch(query: InsurancePriceQuery())
            .valueSignal
            .compactMap { $0.data?.insuranceCost?.fragments.costFragment.monthlyGross }
            .onValue { monthlyGross in
                bag.dispose()
            }
    }
}
