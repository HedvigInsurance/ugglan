//
//  PaymentDetailsSection.swift
//  Hedvig
//
//  Created by Isaac Sennerholt on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct PaymentDetailsSection {
    let client: ApolloClient
    let store: ApolloStore
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController,
        client: ApolloClient = ApolloContainer.shared.client,
        store: ApolloStore = ApolloContainer.shared.store
    ) {
        self.presentingViewController = presentingViewController
        self.client = client
        self.store = store
    }
}

extension PaymentDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let dataValueSignal = client.watch(query: MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        let section = SectionView(
            header: String(key: .MY_PAYMENT_PAYMENT_ROW_LABEL),
            footer: nil,
            style: .sectionPlain
        )

        let freeMonthsRow = KeyValueRow()
        freeMonthsRow.isHiddenSignal.value = true
        freeMonthsRow.keySignal.value = String(key: .MY_PAYMENT_FREE_UNTIL_MESSAGE)

        bag += section.append(freeMonthsRow)

        bag += dataValueSignal
            .compactMap { $0.data?.insurance.cost?.fragments.costFragment.freeUntil }
            .onValue { freeUntilDate in
                freeMonthsRow.valueSignal.value = freeUntilDate
                freeMonthsRow.isHiddenSignal.value = false
            }

        let paymentTypeRow = KeyValueRow()
        paymentTypeRow.keySignal.value = String(key: .MY_PAYMENT_TYPE)
        paymentTypeRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map {
            $0.data?.nextChargeDate
        }.map { paymentDate in
            if let paymentDate = paymentDate {
                return String(key: .MY_PAYMENT_DATE(paymentDate: paymentDate))
            }

            return ""
        }.bindTo(paymentTypeRow.valueSignal)

        bag += section.append(paymentTypeRow)

        let grossPriceRow = KeyValueRow()
        grossPriceRow.keySignal.value = String(key: .PROFILE_PAYMENT_PRICE_LABEL)
        grossPriceRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insurance.cost?.fragments.costFragment.monthlyGross.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return String(key: .PROFILE_PAYMENT_PRICE(price: String(amount)))
                }

                return String(key: .PRICE_MISSING)
            }
            .bindTo(grossPriceRow.valueSignal)

        bag += section.append(grossPriceRow)

        let discountRow = KeyValueRow()
        discountRow.keySignal.value = String(key: .PROFILE_PAYMENT_DISCOUNT_LABEL)
        discountRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insurance.cost?.fragments.costFragment.monthlyDiscount.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return String(key: .PROFILE_PAYMENT_DISCOUNT(discount: String(amount)))
                }

                return String(key: .PRICE_MISSING)
            }
            .bindTo(discountRow.valueSignal)

        bag += section.append(discountRow)

        let netPriceRow = KeyValueRow()
        netPriceRow.keySignal.value = String(key: .PROFILE_PAYMENT_FINAL_COST_LABEL)
        netPriceRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insurance.cost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return String(key: .PROFILE_PAYMENT_FINAL_COST(finalCost: amount))
                }

                return String(key: .PRICE_MISSING)
            }
            .bindTo(netPriceRow.valueSignal)

        bag += section.append(netPriceRow)

        let applyDiscountButtonRow = ButtonRow(text: String(key: .REFERRAL_ADDCOUPON_HEADLINE), style: .normalButton)

        bag += applyDiscountButtonRow.onSelect.onValue { _ in
            let applyDiscount = ApplyDiscount()
            let overlay = DraggableOverlay(
                presentable: applyDiscount,
                presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
            )

            bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
//                self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
//                    data.insurance.cost = MyPaymentQuery.Data.Insurance.Cost(
//                        monthlyDiscount: MyPaymentQuery.Data.Insurance.Cost.MonthlyDiscount(amount: result.cost.monthlyDiscount.amount),
//                        monthlyGross: MyPaymentQuery.Data.Insurance.Cost.MonthlyGross(amount: result.cost.monthlyGross.amount),
//                        monthlyNet: MyPaymentQuery.Data.Insurance.Cost.MonthlyNet(amount: result.cost.monthlyNet.amount)
//                    )
//                })
//
//                self.store.update(query: ReferralsScreenQuery(), updater: { (data: inout ReferralsScreenQuery.Data) in
//                    data.insurance.cost = ReferralsScreenQuery.Data.Insurance.Cost(
//                        monthlyNet: ReferralsScreenQuery.Data.Insurance.Cost.MonthlyNet(amount: result.cost.monthlyNet.amount),
//                        monthlyGross: ReferralsScreenQuery.Data.Insurance.Cost.MonthlyGross(amount: result.cost.monthlyGross.amount)
//                    )
//                })

                let alert = Alert(
                    title: String(key: .REFERRAL_REDEEM_SUCCESS_HEADLINE),
                    message: String(key: .REFERRAL_REDEEM_SUCCESS_BODY),
                    actions: [Alert.Action(title: String(key: .REFERRAL_REDEEM_SUCCESS_BTN)) {}]
                )
                self.presentingViewController.present(alert)
            }

            self.presentingViewController.present(overlay)
        }

        bag += section.append(applyDiscountButtonRow)

        let hidePriceRowsSignal = dataValueSignal.map { $0.data?.insurance.cost?.fragments.costFragment.monthlyDiscount.amount }.toInt().map { $0 == 0 }
        let hasFreeMonths = dataValueSignal.map { $0.data?.insurance.cost?.fragments.costFragment.freeUntil != nil }
        bag += hidePriceRowsSignal.bindTo(grossPriceRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(discountRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(netPriceRow.isHiddenSignal)
        bag += combineLatest(hidePriceRowsSignal, hasFreeMonths).map { !$0 || $1 }.bindTo(applyDiscountButtonRow.isHiddenSignal)

        return (section, bag)
    }
}
