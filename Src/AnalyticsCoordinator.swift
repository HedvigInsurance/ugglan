//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Apollo
import FBSDKCoreKit
import Firebase
import Flow
import Foundation

struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient
    @Inject private var remoteConfig: RemoteConfigContainer

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
        AppEvents.logEvent(
            .addedPaymentInfo
        )

        Analytics.logEvent("add_payment_info", parameters: [:])
    }

    func logAddToCart() {
        let bag = DisposeBag()
        bag += client.fetch(query: InsurancePriceQuery())
            .valueSignal
            .compactMap { $0.data?.insurance.cost?.fragments.costFragment.monthlyGross }
            .onValue { monthlyGross in
                bag.dispose()

                AppEvents.logEvent(
                    .addedToCart,
                    valueToSum: Double(monthlyGross.amount) ?? 0,
                    parameters: [
                        "currency": monthlyGross.currency,
                    ]
                )

                Analytics.logEvent("add_to_cart", parameters: [
                    "value": Double(monthlyGross.amount) ?? 0,
                    "currency": monthlyGross.currency,
                ])
            }
    }

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
