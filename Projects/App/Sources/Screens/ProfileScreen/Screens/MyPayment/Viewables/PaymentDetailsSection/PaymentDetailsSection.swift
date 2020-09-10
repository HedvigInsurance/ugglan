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
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

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

        let dataSignal = client.watch(query: GraphQL.MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        let section = SectionView(
            header: L10n.myPaymentPaymentRowLabel,
            footer: nil
        )

        let grossPriceRow = KeyValueRow()
        grossPriceRow.keySignal.value = L10n.profilePaymentPriceLabel
        grossPriceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map { $0.insuranceCost?.fragments.costFragment.monthlyGross.amount }
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
        discountRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map { $0.insuranceCost?.fragments.costFragment.monthlyDiscount.amount }
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
        netPriceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map { $0.insuranceCost?.fragments.costFragment.monthlyNet.amount }
            .toInt()
            .map { amount in
                if let amount = amount {
                    return L10n.profilePaymentFinalCost(String(amount))
                }

                return L10n.priceMissing
            }
            .bindTo(netPriceRow.valueSignal)

        bag += section.append(netPriceRow)

        let applyDiscountButtonRow = ButtonRow(text: L10n.referralAddcouponHeadline, style: .brand(.headline(color: .link)))

        bag += applyDiscountButtonRow.onSelect.onValue { _ in
            let applyDiscount = ApplyDiscount()

            bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                self.store.update(query: GraphQL.MyPaymentQuery(), updater: { (data: inout GraphQL.MyPaymentQuery.Data) in
                    data.insuranceCost?.fragments.costFragment = result.cost.fragments.costFragment
                })

                self.store.update(query: GraphQL.ReferralsScreenQuery(), updater: { (data: inout GraphQL.ReferralsScreenQuery.Data) in
                    data.insuranceCost?.fragments.costFragment = result.cost.fragments.costFragment
                })

                let alert = Alert(
                    title: L10n.discountRedeemSuccess,
                    message: L10n.discountRedeemSuccessBody,
                    actions: [Alert.Action(title: L10n.discountRedeemSuccessButton) {}]
                )
                self.presentingViewController.present(alert)
            }

            self.presentingViewController.present(
                applyDiscount.withCloseButton,
                style: .detented(.scrollViewContentSize(20), .large),
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }

        bag += section.append(applyDiscountButtonRow)

        let hidePriceRowsSignal = dataSignal.map { $0.insuranceCost?.fragments.costFragment.monthlyDiscount.amount }.toInt().map { $0 == 0 }
        let hasFreeMonths = dataSignal.map { $0.insuranceCost?.fragments.costFragment.freeUntil != nil }
        bag += hidePriceRowsSignal.bindTo(grossPriceRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(discountRow.isHiddenSignal)
        bag += hidePriceRowsSignal.bindTo(netPriceRow.isHiddenSignal)
        bag += combineLatest(hidePriceRowsSignal, hasFreeMonths).map { !$0 || $1 }.bindTo(applyDiscountButtonRow.isHiddenSignal)

        return (section, bag)
    }
}
