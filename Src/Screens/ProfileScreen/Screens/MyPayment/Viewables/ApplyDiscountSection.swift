//
//  ApplyDiscountSection.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-18.
//

import Apollo
import Flow
import Form
import Foundation

struct ApplyDiscountSection {
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

extension ApplyDiscountSection: Viewable {
    func materialize(events _: ViewableEvents) -> (ButtonSection, Disposable) {
        let bag = DisposeBag()

        let buttonSection = ButtonSection(text: String(key: .REFERRAL_ADDCOUPON_HEADLINE), style: .normal)

        bag += buttonSection.onSelect.onValue { _ in
            let applyDiscount = ApplyDiscount()
            let overlay = DraggableOverlay(
                presentable: applyDiscount,
                presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
            )

            bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                self.store.update(query: InsurancePriceQuery(), updater: { (data: inout InsurancePriceQuery.Data) in
                    data.insurance.cost = InsurancePriceQuery.Data.Insurance.Cost(
                        monthlyDiscount: InsurancePriceQuery.Data.Insurance.Cost.MonthlyDiscount(amount: result.cost.monthlyDiscount.amount),
                        monthlyGross: InsurancePriceQuery.Data.Insurance.Cost.MonthlyGross(amount: result.cost.monthlyGross.amount),
                        monthlyNet: InsurancePriceQuery.Data.Insurance.Cost.MonthlyNet(amount: result.cost.monthlyNet.amount)
                    )
                })

                self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
                    data.insurance.cost = MyPaymentQuery.Data.Insurance.Cost(
                        monthlyDiscount: MyPaymentQuery.Data.Insurance.Cost.MonthlyDiscount(amount: result.cost.monthlyDiscount.amount),
                        monthlyGross: MyPaymentQuery.Data.Insurance.Cost.MonthlyGross(amount: result.cost.monthlyGross.amount),
                        monthlyNet: MyPaymentQuery.Data.Insurance.Cost.MonthlyNet(amount: result.cost.monthlyNet.amount)
                    )
                })
            }

            self.presentingViewController.present(overlay)
        }

        return (buttonSection, bag)
    }
}
