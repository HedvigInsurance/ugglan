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
    @Inject var client: ApolloClient
}

extension MyPayment: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let dataSignal = self.client.watch(query: MyPaymentQuery()).map { $0.data }
        let failedChargesSignalData = dataSignal.map { $0?.balance.failedCharges }
        let nextPaymentSignalData = dataSignal.map { $0?.nextChargeDate }

        let viewController = UIViewController()
        viewController.title = String(key: .MY_PAYMENT_TITLE)

        let form = FormView()
        bag += viewController.install(form)
        
        bag += combineLatest(failedChargesSignalData, nextPaymentSignalData).onValue({ failedCharges, nextPayment in
            guard let failedCharges = failedCharges else { return }
            guard let nextPayment = nextPayment else { return }
  
            if failedCharges == 0 {
                let latePaymentHeaderCard = LatePaymentHeaderSection(failedCharges: failedCharges, lastDate: nextPayment)
                bag += form.prepend(latePaymentHeaderCard)
            }
        })

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

        let bankDetailsSection = BankDetailsSection()
        bag += form.append(bankDetailsSection)

        bag += form.append(Spacing(height: 20))

        let buttonSection = ButtonSection(
            text: "",
            style: .normal
        )
        bag += form.append(buttonSection)

        let buttonSectionWeb = ButtonSection(
            text: String(key: .PROFILE_PAYMENT_CONNECT_DIRECT_DEBIT_WITH_LINK_BUTTON),
            style: .normal
        )
        bag += form.append(buttonSectionWeb)

        let myPaymentQuerySignal = client.watch(query: MyPaymentQuery(), cachePolicy: .returnCacheDataAndFetch)

        bag += myPaymentQuerySignal.onValueDisposePrevious { result in
            let innerBag = bag.innerBag()
            
            print(result)

            let hasAlreadyConnected = result.data?.bankAccount != nil
            buttonSection.text.value = hasAlreadyConnected ? String(key: .MY_PAYMENT_DIRECT_DEBIT_REPLACE_BUTTON) : String(key: .MY_PAYMENT_DIRECT_DEBIT_BUTTON)

            innerBag += buttonSection.onSelect.onValue {
                let directDebitSetup = DirectDebitSetup(
                    setupType: hasAlreadyConnected ? .replacement : .initial
                )
                viewController.present(directDebitSetup, options: [.autoPop])
            }

            innerBag += buttonSectionWeb.onSelect.onValue {
                bag += self.client.perform(mutation: StartDirectDebitRegistrationMutation())
                    .valueSignal
                    .compactMap { $0.data?.startDirectDebitRegistration }
                    .onValue { startDirectDebitRegistration in
                        guard let url = URL(string: startDirectDebitRegistration) else { return }
                        UIApplication.shared.open(url)
                    }
            }

            if result.data?.directDebitStatus == .pending {
                updatingMessageSectionSpacing.isHiddenSignal.value = false
                updatingMessageSection.isHidden = false
                buttonSection.isHiddenSignal.value = true
                buttonSectionWeb.isHiddenSignal.value = true
                bankDetailsSection.isHiddenSignal.value = true
            } else {
                updatingMessageSectionSpacing.isHiddenSignal.value = true
                updatingMessageSection.isHidden = true
                buttonSection.isHiddenSignal.value = false
                buttonSectionWeb.isHiddenSignal.value = hasAlreadyConnected
                bankDetailsSection.isHiddenSignal.value = false
            }

            return innerBag
        }

        return (viewController, bag)
    }
}
