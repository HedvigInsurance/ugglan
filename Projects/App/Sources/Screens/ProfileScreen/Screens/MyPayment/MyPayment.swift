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
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct MyPayment {
    @Inject var client: ApolloClient
}

extension MyPayment: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let dataSignal = client.watch(query: GraphQL.MyPaymentQuery())
        let failedChargesSignalData = dataSignal.map { $0.balance.failedCharges }
        let nextPaymentSignalData = dataSignal.map { $0.nextChargeDate }

        let viewController = UIViewController()
        viewController.title = L10n.myPaymentTitle

        let form = FormView()
        bag += viewController.install(form) { scrollView in
            bag += scrollView.performEntryAnimation(
                contentView: form,
                onLoad: self.client.fetch(query: GraphQL.MyPaymentQuery()),
                onError: { _ in }
            )
        }
        bag += dataSignal.animated(style: SpringAnimationStyle.lightBounce()) { _ in
            form.alpha = 1
            form.transform = CGAffineTransform.identity
        }

        let failedChargesSpacing = Spacing(height: 20)
        failedChargesSpacing.isHiddenSignal.value = true

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

        bag += failedChargesSignalData.onValue { failedCharges in
            if failedCharges != nil {
                failedChargesSpacing.isHiddenSignal.value = false
            }
        }

        bag += form.prepend(failedChargesSpacing)

        bag += form.append(updatingMessageSectionSpacing)

        let updatingMessageSection = SectionView()
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

        let myPaymentQuerySignal = client.watch(query: GraphQL.MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        bag += myPaymentQuerySignal.onValueDisposePrevious { data in
            let innerBag = bag.innerBag()

            let hasAlreadyConnected = data.payinMethodStatus != .needsSetup
            buttonSection.text.value = hasAlreadyConnected ? L10n.myPaymentDirectDebitReplaceButton : L10n.myPaymentDirectDebitButton

            innerBag += buttonSection.onSelect.onValue {
                let setup = PaymentSetup(
                    setupType: hasAlreadyConnected ? .replacement : .initial
                )
                viewController.present(setup, style: .modally(), options: [.defaults, .allowSwipeDismissAlways])
            }

            if data.payinMethodStatus == .pending {
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
