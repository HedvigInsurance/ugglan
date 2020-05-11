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
import Core

struct PaymentDetailsSection {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }
}

extension PaymentDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let dataValueSignal = client.watch(query: MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        let section = SectionView(
            header: L10n.myPaymentPaymentRowLabel,
            footer: nil,
            style: .sectionPlain
        )

        let grossPriceRow = KeyValueRow()
        grossPriceRow.keySignal.value = L10n.profilePaymentPriceLabel
        grossPriceRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insuranceCost?.fragments.costFragment.monthlyGross.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return L10n.profilePaymentPrice(String(amount))
                }

                return L10n.priceMissing
            }
            .bindTo(grossPriceRow.valueSignal)

        bag += section.append(grossPriceRow)

        let discountRow = KeyValueRow()
        discountRow.keySignal.value = L10n.profilePaymentDiscountLabel
        discountRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insuranceCost?.fragments.costFragment.monthlyDiscount.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return L10n.profilePaymentDiscount(String(amount))
                }

                return L10n.priceMissing
            }
            .bindTo(discountRow.valueSignal)

        bag += section.append(discountRow)

        let netPriceRow = KeyValueRow()
        netPriceRow.keySignal.value = L10n.profilePaymentFinalCostLabel
        netPriceRow.valueStyleSignal.value = .rowTitleDisabled

        bag += dataValueSignal.map { $0.data?.insuranceCost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return L10n.profilePaymentFinalCost(String(amount))
                }

                return L10n.priceMissing
            }
            .bindTo(netPriceRow.valueSignal)

        bag += section.append(netPriceRow)

        let applyDiscountButtonRow = ButtonRow(text: L10n.referralAddcouponHeadline, style: .normalButton)

        bag += applyDiscountButtonRow.onSelect.onValue { _ in
            let applyDiscount = ApplyDiscount()

            bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
                    data.insuranceCost?.fragments.costFragment = result.cost.fragments.costFragment
                })

                self.store.update(query: ReferralsScreenQuery(), updater: { (data: inout ReferralsScreenQuery.Data) in
                    data.insuranceCost?.fragments.costFragment = result.cost.fragments.costFragment
                })

                let alert = Alert(
                    title: L10n.referralRedeemSuccessHeadline,
                    message: L10n.referralRedeemSuccessBody,
                    actions: [Alert.Action(title: L10n.referralRedeemSuccessBtn) {}]
                )
                self.presentingViewController.present(alert)
            }

            self.presentingViewController.present(applyDiscount.withCloseButton, style: .modally())
        }

        bag += section.append(applyDiscountButtonRow)

        let hidePriceRowsSignal = dataValueSignal.map { $0.data?.insuranceCost?.fragments.costFragment.monthlyDiscount.amount }.toInt().map { $0 == 0 }
        let hasFreeMonths = dataValueSignal.map { $0.data?.insuranceCost?.fragments.costFragment.freeUntil != nil }
        bag += hidePriceRowsSignal.bindTo(grossPriceRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(discountRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(netPriceRow.isHiddenSignal)
        bag += combineLatest(hidePriceRowsSignal, hasFreeMonths).map { !$0 || $1 }.bindTo(applyDiscountButtonRow.isHiddenSignal)

        return (section, bag)
    }
}
