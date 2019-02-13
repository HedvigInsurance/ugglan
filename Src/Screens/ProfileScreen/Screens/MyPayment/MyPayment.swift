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

        bag += client.fetch(query: ProfileQuery()).onValue { result in
            if let insurance = result.data?.insurance {
                let monthlyPaymentCircle = MonthlyPaymentCircle(monthlyCost: insurance.monthlyCost ?? 0)
                bag += form.prepend(monthlyPaymentCircle)

                let paymentDetailsSection = PaymentDetailsSection(insurance: insurance)
                bag += form.append(paymentDetailsSection)

                let bankDetailsSection = BankDetailsSection(insurance: insurance)
                bag += form.append(bankDetailsSection)
            }

            bag += form.append(Spacing(height: 20))

            let buttonSection = ButtonSection(
                text: "Ändra bankkonto",
                style: .normal
            )
            bag += form.append(buttonSection)

            bag += buttonSection.onSelect.onValue {
                viewController.present(DirectDebitSetup(), options: [.autoPop])
            }
        }

        return (viewController, bag)
    }
}
