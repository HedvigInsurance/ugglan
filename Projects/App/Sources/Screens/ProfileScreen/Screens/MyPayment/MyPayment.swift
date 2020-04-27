//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Adyen
import AdyenDropIn
import Apollo
import Flow
import Form
import Presentation
import UIKit

struct MyPayment {
    @Inject var client: ApolloClient
}

extension MyPayment: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let dataSignal = client.watch(query: MyPaymentQuery()).map { $0.data }
        let failedChargesSignalData = dataSignal.map { $0?.balance.failedCharges }
        let nextPaymentSignalData = dataSignal.map { $0?.nextChargeDate }

        let viewController = UIViewController()
        viewController.title = String(key: .MY_PAYMENT_TITLE)

        let form = FormView()
        bag += viewController.install(form)

        form.alpha = 0
        form.transform = CGAffineTransform(translationX: 0, y: 100)

        bag += dataSignal.animated(style: SpringAnimationStyle.lightBounce()) { _ in
            form.alpha = 1
            form.transform = CGAffineTransform.identity
        }

        bag += combineLatest(failedChargesSignalData, nextPaymentSignalData).onValueDisposePrevious { failedCharges, nextPayment in
            let innerbag = DisposeBag()
            if let failedCharges = failedCharges, let nextPayment = nextPayment {
                if failedCharges > 0 {
                    let latePaymentHeaderCard = LatePaymentHeaderSection(failedCharges: failedCharges, lastDate: nextPayment)
                    innerbag += form.prepend(latePaymentHeaderCard)
                }
            }
            return innerbag
        }

        let paymentHeaderCard = PaymentHeaderCard()
        bag += form.prepend(paymentHeaderCard)

        let updatingMessageSectionSpacing = Spacing(height: 20)
        updatingMessageSectionSpacing.isHiddenSignal.value = true

        bag += form.append(updatingMessageSectionSpacing)

        let updatingMessageSection = SectionView(style: .sectionPlain)
        updatingMessageSection.isHidden = true

        let updatingMessage = UpdatingMessage()
        bag += updatingMessageSection.append(updatingMessage)

        form.append(updatingMessageSection)

        let pastPaymentsSection = PastPaymentsSection(presentingViewController: viewController)
        bag += form.append(pastPaymentsSection)

        let paymentDetailsSection = PaymentDetailsSection(presentingViewController: viewController)
        bag += form.append(paymentDetailsSection)

        switch Localization.Locale.currentLocale.market {
        case .se:
            let bankDetailsSection = BankDetailsSection()
            bag += form.append(bankDetailsSection)
        case .no:
            let cardDetailsSection = CardDetailsSection()
            bag += form.append(cardDetailsSection)
        }

        bag += form.append(Spacing(height: 20))

        let buttonSection = ButtonSection(
            text: "",
            style: .normal
        )
        bag += form.append(buttonSection)

        let myPaymentQuerySignal = client.watch(query: MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        bag += myPaymentQuerySignal.onValueDisposePrevious { result in
            let innerBag = bag.innerBag()

            let hasAlreadyConnected = result.data?.payinMethodStatus != .needsSetup
            buttonSection.text.value = hasAlreadyConnected ? String(key: .MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON) : String(key: .MY_PAYMENT_DIRECT_DEBIT_BUTTON)

            innerBag += buttonSection.onSelect.onValue {
                let setup = PaymentSetup(
                    setupType: hasAlreadyConnected ? .replacement : .initial
                )
                viewController.present(setup, style: .modally(), options: [.defaults, .allowSwipeDismissAlways])
            }

            if result.data?.payinMethodStatus == .pending {
                updatingMessageSectionSpacing.isHiddenSignal.value = false
                updatingMessageSection.isHidden = false
                buttonSection.isHiddenSignal.value = true
            } else {
                updatingMessageSectionSpacing.isHiddenSignal.value = true
                updatingMessageSection.isHidden = true
                buttonSection.isHiddenSignal.value = false
            }

            return innerBag
        }

        return (viewController, bag)
    }
}
