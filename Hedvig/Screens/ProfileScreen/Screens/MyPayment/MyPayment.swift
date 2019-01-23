//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation

struct MyPayment {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension MyPayment: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String.translation(.MY_PAYMENT_TITLE)

        let form = FormView()

        bag += viewController.install(form) { scrollView in
            bag += scrollView.chainAllControlResponders(shouldLoop: false, returnKey: .next)
        }

        bag += client.fetch(query: ProfileQuery()).onValue { result in
            if let insurance = result.data?.insurance {
                let monthlyPaymentCircle = MonthlyPaymentCircle(monthlyCost: insurance.monthlyCost ?? Int(0))
                bag += form.prepend(monthlyPaymentCircle)
            }
        }

        return (viewController, bag)
    }
}
