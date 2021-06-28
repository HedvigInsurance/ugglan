import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct Checkout {
	@Inject var state: OfferState
}

enum CheckoutError: Error {
    case signingFailed
}

extension Checkout: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let checkoutButton = CheckoutButton()
		let viewController = AccessoryViewController(accessoryView: checkoutButton)
		viewController.title = L10n.checkoutTitle
		let bag = DisposeBag()

		let form = FormView()
		bag += viewController.install(form)

		bag += state.dataSignal.compactMap { $0.quoteBundle }
			.onFirstValue({ quoteBundle in
				let header = UIStackView()
				header.spacing = 16
				header.axis = .vertical

				let titleLabel = MultilineLabel(
					value: quoteBundle.quotes.reduce(
						"",
						{ previousString, quote in
							return previousString.isEmpty
								? quote.displayName
								: "\(previousString) + \n\(quote.displayName)"
						}
					),
					style: TextStyle.brand(.title1(color: .secondary))
						.restyled({ (style: inout TextStyle) in
							style.lineHeight = quoteBundle.quotes.count > 1 ? 45 : 0
						})
				)
				bag += header.addArranged(titleLabel)

				bag += header.addArrangedSubview(PriceRow(placement: .checkout))

				let section = SectionView(headerView: header, footerView: nil)

				form.append(section)
                
                let emailMasking = Masking(type: .email)

                let emailRow = RowView(title: emailMasking.helperText ?? "", style: .brand(.title3(color: .primary)))
				emailRow.alignment = .leading
				emailRow.axis = .vertical
				emailRow.distribution = .fill
				section.append(emailRow)

				let emailTextField = UITextField(
					value: "",
                    placeholder: emailMasking.placeholderText ?? "",
					style: .default
				)
				emailTextField.returnKeyType = .next
				emailMasking.applySettings(emailTextField)
				emailTextField.clearButtonMode = .whileEditing
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
				ssnTextField.clearButtonMode = .whileEditing
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
								state.checkoutUpdate(
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
						}
					}

				bag +=
					isValidSignal
					.bindTo(checkoutButton.$isEnabled)
			})

		return (
			viewController,
			Future { completion in
            
                func toggleAllowDismissal() {
                    if #available(iOS 13.0, *) {
                        viewController.isModalInPresentation = !viewController.isModalInPresentation
                    }
                    viewController.navigationItem.rightBarButtonItem?.isEnabled = !(viewController.navigationItem.rightBarButtonItem?.isEnabled ?? true)
                }
            
            func handleError() {
                toggleAllowDismissal()
                checkoutButton.$isLoading.value = false
                
                let alert = Alert<Void>(
                    title: L10n.simpleSignFailedTitle,
                    message: L10n.simpleSignFailedMessage,
                    actions: [
                        Alert.Action(
                            title: L10n.alertOk,
                            action: { _ in
                                
                            }
                        )
                    ]
                )

                viewController.present(alert)
            }
            
                bag += checkoutButton.onTapSignal.onValue { _ in
                    checkoutButton.$isLoading.value = true
                    
                    toggleAllowDismissal()
                    
                    state.signQuotes().onValue { signEvent in
                        switch signEvent {
                        case .swedishBankId, .failed:
                            handleError()
                        case let .simpleSign(subscription):
                            bag += subscription.filter { $0.signStatus?.status?.signState == .failed }.onFirstValue { _ in
                                handleError()
                            }
                            
                            bag += subscription.filter { $0.signStatus?.status?.signState == .completed }.onValue { _ in
                                completion(.success)
                            }
                        case .done:
                            completion(.success)
                        }
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
		}
	}
}
