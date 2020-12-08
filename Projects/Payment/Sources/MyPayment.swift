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

public struct MyPayment {
    @Inject var client: ApolloClient
    let urlScheme: String

    public init(urlScheme: String) {
        self.urlScheme = urlScheme
    }
}

extension MyPayment: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
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
            let bankDetailsSection = BankDetailsSection(urlScheme: urlScheme)
            bag += form.append(bankDetailsSection)
        case .no, .dk:
            let cardDetailsSection = CardDetailsSection(urlScheme: urlScheme)
            bag += form.append(cardDetailsSection)

            let payoutDetailsSection = PayoutDetailsSection(urlScheme: urlScheme)
            bag += form.append(payoutDetailsSection)
        }

        bag += form.append(Spacing(height: 20))

        return (viewController, bag)
    }
}
