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

    init(
        client: ApolloClient = HedvigApolloClient.shared.client!
    ) {
        self.client = client
    }
}

extension MyPayment: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(.MY_PAYMENT_TITLE)

        let form = FormView()
        bag += viewController.install(form)

        bag += client.fetch(query: MyPaymentQuery()).onValue { result in
            let monthlyPaymentCircle = MonthlyPaymentCircle(
                monthlyCost: result.data?.insurance.monthlyCost ?? 0
            )
            bag += form.prepend(monthlyPaymentCircle)

            let paymentDetailsSection = PaymentDetailsSection()
            bag += form.append(paymentDetailsSection)

            let bankDetailsSection = BankDetailsSection()
            bag += form.append(bankDetailsSection)

            bag += form.append(Spacing(height: 20))

            let hasAlreadyConnected = result.data?.bankAccount != nil

            let buttonText = hasAlreadyConnected ? String(.MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON) : String(.MY_PAYMENT_DIRECT_DEBIT_BUTTON)
            let buttonSection = ButtonSection(
                text: buttonText,
                style: .normal
            )
            bag += form.append(buttonSection)

            bag += buttonSection.onSelect.onValue {
                let directDebitSetup = DirectDebitSetup(
                    setupType: hasAlreadyConnected ? .replacement : .initial
                )
                viewController.present(directDebitSetup, options: [.autoPop])
            }
        }

        return (viewController, bag)
    }
}
