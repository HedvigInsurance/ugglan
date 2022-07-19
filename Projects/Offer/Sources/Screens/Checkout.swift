import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

public struct Checkout {
    public var paymentConnectionID: String

    public init(
        paymentConnectionID: String
    ) {
        self.paymentConnectionID = paymentConnectionID
    }
}

enum CheckoutError: Error {
    case signingFailed
}

extension Checkout: Presentable {
    func handleError(
        title: String,
        message: String,
        viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let alert = Alert<Void>(
            title: title,
            message: message,
            actions: [
                Alert.Action(
                    title: L10n.alertOk,
                    action: completion
                )
            ]
        )

        viewController.present(alert)
    }

    public func materialize() -> (UIViewController, FiniteSignal<Void>) {
        let checkoutButton = CheckoutButton()
        let viewController = AccessoryViewController(accessoryView: checkoutButton)
        viewController.title = L10n.checkoutTitle
        let bag = DisposeBag()

        let store: OfferStore = self.get()
        store.send(.setPaymentConnectionID(id: paymentConnectionID))

        let form = FormView()
        bag += viewController.install(form)

        bag += store.stateSignal.atOnce().compactMap { $0.currentVariant?.bundle }
            .onFirstValue({ quoteBundle in
                let header = UIStackView()
                header.spacing = 16
                header.axis = .vertical

                header.addArrangedSubview(
                    HostingView(
                        rootView: hText(quoteBundle.displayName, style: .title1)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
                )

                bag += header.addArrangedSubview(PriceRow(placement: .checkout))

                let section = SectionView(headerView: header, footerView: nil)

                form.append(section)

                let emailMasking = Masking(type: .email)

                let emailRow = RowView(
                    title: emailMasking.helperText ?? "",
                    style: .brand(.title3(color: .primary))
                )
                emailRow.alignment = .leading
                emailRow.axis = .vertical
                emailRow.distribution = .fill
                section.append(emailRow)

                let emailTextField = UITextField(
                    value: quoteBundle.quotes.first?.email ?? "",
                    placeholder: emailMasking.placeholderText ?? "",
                    style: .default
                )
                emailTextField.returnKeyType = .next
                emailMasking.applySettings(emailTextField)
                emailTextField.becomeFirstResponder()
                emailRow.append(emailTextField)

                bag += emailMasking.applyMasking(emailTextField)

                let ssnMasking = Localization.Locale.currentLocale.market.masking

                let ssnRow = RowView(
                    title: ssnMasking.helperText ?? "",
                    style: .brand(.title3(color: .primary))
                )
                ssnRow.alignment = .leading
                ssnRow.axis = .vertical
                ssnRow.distribution = .fill
                section.append(ssnRow)

                let ssnTextField = UITextField(
                    value: "",
                    placeholder: ssnMasking.placeholderText ?? "",
                    style: .default
                )
                ssnMasking.applySettings(ssnTextField)
                ssnRow.append(ssnTextField)

                bag += ssnMasking.applyMasking(ssnTextField)

                bag += form.chainAllControlResponders()

                let isValidSignal = combineLatest(
                    ssnMasking.isValidSignal(ssnTextField),
                    emailMasking.isValidSignal(emailTextField)
                )
                .map { ssnValid, emailValid in ssnValid && emailValid }

                bag += isValidSignal.filter { valid in valid }
                    .onValue { _ in
                        checkoutButton.$isLoading.value = true

                        join(
                            quoteBundle.quotes.map { quote in
                                store.checkoutUpdate(
                                    quoteId: quote.id,
                                    email: emailMasking.unmaskedValue(
                                        text: emailTextField.value
                                    ),
                                    ssn: ssnMasking.unmaskedValue(
                                        text: ssnTextField.value
                                    )
                                )
                            }
                        )
                        .onValue { _ in
                            checkoutButton.$isLoading.value = false
                            checkoutButton.$isEnabled.value = true
                        }
                        .onError { error in
                            handleError(
                                title: L10n.simpleSignFailedTitle,
                                message: L10n.simpleSignFailedMessage,
                                viewController: viewController
                            ) {
                                checkoutButton.$isEnabled.value = false
                                checkoutButton.$isLoading.value = false
                            }
                        }
                    }
            })

        return (
            viewController,
            FiniteSignal { callback in

                func toggleAllowDismissal() {
                    viewController.isModalInPresentation = !viewController
                        .isModalInPresentation
                    viewController.navigationItem.rightBarButtonItem?.isEnabled =
                        !(viewController.navigationItem.rightBarButtonItem?.isEnabled ?? true)
                }

                func handleError() {
                    self.handleError(
                        title: L10n.simpleSignFailedTitle,
                        message: L10n.simpleSignFailedMessage,
                        viewController: viewController
                    ) {
                        toggleAllowDismissal()
                        checkoutButton.$isLoading.value = false
                    }
                }

                bag += checkoutButton.onTapSignal.onValue { _ in
                    checkoutButton.$isLoading.value = true

                    toggleAllowDismissal()

                    let store: OfferStore = get()
                    store.send(.startSign)

                    bag += store.onAction(.sign(event: .failed)) {
                        handleError()
                    }

                    bag += store.onAction(.sign(event: .done)) {
                        callback(.value(()))
                    }
                }

                return bag
            }
        )
    }
}

extension Localization.Locale.Market {
    fileprivate var masking: Masking {
        switch self {
        case .no: return .init(type: .norwegianPersonalNumber)
        case .se: return .init(type: .personalNumber)
        case .dk: return .init(type: .danishPersonalNumber)
        case .fr: return .init(type: .email)
        }
    }
}
