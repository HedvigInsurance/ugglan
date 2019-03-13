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

        let monthlyPaymentCircle = MonthlyPaymentCircle()
        bag += form.prepend(monthlyPaymentCircle)

        let updatingMessageSectionSpacing = Spacing(height: 20)
        updatingMessageSectionSpacing.isHiddenSignal.value = true

        bag += form.append(updatingMessageSectionSpacing)

        let updatingMessageSection = SectionView(style: .sectionPlain)
        updatingMessageSection.isHidden = true

        let updatingMessage = UpdatingMessage()
        bag += updatingMessageSection.append(updatingMessage)

        form.append(updatingMessageSection)

        let paymentDetailsSection = PaymentDetailsSection()
        bag += form.append(paymentDetailsSection)

        let bankDetailsSection = BankDetailsSection()
        bag += form.append(bankDetailsSection)

        bag += form.append(Spacing(height: 20))

        let buttonSection = ButtonSection(
            text: "",
            style: .normal
        )
        bag += form.append(buttonSection)

        bag += client.watch(query: MyPaymentQuery()).onValueDisposePrevious { result in
            let innerBag = bag.innerBag()

            monthlyPaymentCircle.monthlyCostSignal.value = result.data?.insurance.monthlyCost

            let hasAlreadyConnected = result.data?.bankAccount != nil
            buttonSection.text.value = hasAlreadyConnected ? String(.MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON) : String(.MY_PAYMENT_DIRECT_DEBIT_BUTTON)

            innerBag += buttonSection.onSelect.onValue {
                let directDebitSetup = DirectDebitSetup(
                    setupType: hasAlreadyConnected ? .replacement : .initial
                )
                viewController.present(directDebitSetup, options: [.autoPop])
            }

            if result.data?.directDebitStatus == .pending {
                updatingMessageSectionSpacing.isHiddenSignal.value = false
                updatingMessageSection.isHidden = false
                buttonSection.isHiddenSignal.value = true
                bankDetailsSection.isHiddenSignal.value = true
            } else {
                updatingMessageSectionSpacing.isHiddenSignal.value = true
                updatingMessageSection.isHidden = true
                buttonSection.isHiddenSignal.value = false
                bankDetailsSection.isHiddenSignal.value = false
            }

            return innerBag
        }

        return (viewController, bag)
    }
}
