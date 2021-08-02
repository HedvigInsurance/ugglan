import Flow
import Foundation
import Hero
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkAddressAutocompleteData = EmbarkPassage.Action.AsEmbarkAddressAutocompleteAction

struct EmbarkAddressAutocompleteAction: AddressTransitionable {
	var boxFrame: ReadWriteSignal<CGRect?> = ReadWriteSignal(CGRect.zero)
	var isTransitioningSignal = ReadWriteSignal<Bool>(false)
	let state: EmbarkState
	let data: EmbarkAddressAutocompleteData
	let addressState = AddressState()

	var prefillValue: String {
		guard let value = state.store.getPrefillValue(key: data.addressAutocompleteActionData.key) else {
			return ""
		}

		return value
	}
}

extension EmbarkAddressAutocompleteAction: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
		let view = UIStackView()
		view.axis = .vertical
		view.spacing = 10

		let bag = DisposeBag()

		let box = UIControl()
		view.addArrangedSubview(box)

		let addressInput = AddressInput(
			placeholder: data.addressAutocompleteActionData.placeholder,
			addressState: addressState
		)
		addressState.textSignal.value = prefillValue
		bag += box.add(addressInput) { addressInputView in
			addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		}
		bag += box.didMoveToWindowSignal.delay(by: 0.5)
			.onValue { _ in addressInput.setIsFirstResponderSignal.value = true }

		let touchSignal = box.signal(for: .touchUpInside).atOnce()
		let typeSignal = addressState.textSignal.latestTwo().filter { $0.1.count - $0.0.count == 1 }.toVoid()

		bag += combineLatest(touchSignal, typeSignal)
			.filter { _ in !isTransitioningSignal.value }
			.onValueDisposePrevious { _ -> Disposable in
				let bag = DisposeBag()
				isTransitioningSignal.value = true

				let autocompleteView = EmbarkAddressAutocomplete(
					state: self.state,
					data: self.data,
					addressState: self.addressState
				)

				let interimAddressInput = AddressInput(
					placeholder: data.addressAutocompleteActionData.placeholder,
					addressState: addressState
				)
				let transition = AddressTransition(
					firstBox: box,
					secondBox: autocompleteView.box,
					addressInput: interimAddressInput
				)

				bag += transition.didStartTransitionSignal.onValueDisposePrevious {
					presenting -> Disposable in
					let innerBag = DisposeBag()
					//interimAddressInput.text =
					//	presenting ? addressInput.text : autocompleteView.text
					//if presenting {
					//	innerBag += addressInput.textSignal.onValue { text in
					//		interimAddressInput.text = text
					//	}
					//}
					return innerBag
				}

				bag += transition.didEndTransitionSignal.onValue { presenting in
					if presenting {
						//autocompleteView.text = interimAddressInput.text
						autocompleteView.setIsFirstResponderSignal.value = true
					} else {
						//addressInput.text = interimAddressInput.text
						addressInput.setIsFirstResponderSignal.value = true
						//addressInput.postalCodeSignal.value =
						//	addressState.formatPostalLine(
						//		from: addressState.pickedSuggestionSignal.value
						//	) ?? ""
					}
				}

				box.viewController?
					.present(
						autocompleteView.wrappedInCloseButton(),
						style: .address(transition: transition)
					)
					.onValue { address in
						print("DONE HERE:", address)
						isTransitioningSignal.value = false
					}
					.onError { _ in
						// Didn't find no address
						print("Errore")
						isTransitioningSignal.value = false
					}
				return bag
			}

		let button = Button(
			title: data.addressAutocompleteActionData.link.fragments.embarkLinkFragment.label,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += view.addArranged(button)

		bag += addressState.textSignal.atOnce().map { text in !text.isEmpty }
			.bindTo(button.isEnabled)

		return (
			view,
			Signal { callback in
				func complete(_ value: String) {
					if let passageName = self.state.passageNameSignal.value {
						self.state.store.setValue(key: "\(passageName)Result", value: value)
					}

					self.state.store.setValue(
						key: self.data.addressAutocompleteActionData.key,
						value: value
					)

					self.state.store.createRevision()

					if let apiFragment = self.data.addressAutocompleteActionData.api?.fragments
						.apiFragment
					{
						bag += self.state.handleApi(apiFragment: apiFragment)
							.onValue { link in guard let link = link else { return }
								callback(link)
							}
					} else {
						callback(
							self.data.addressAutocompleteActionData.link.fragments
								.embarkLinkFragment
						)
					}
				}

				//bag += box.signal(for: .touchUpInside)
				//	.onValue { _ in
				/*let autocompleteView = EmbarkAddressAutocomplete(
							state: self.state,
							data: self.data
						)*/

				/*box.viewController?
							.present(
								autocompleteView,
                                style: .address(firstView: box, secondView: autocompleteView.box)
							)*/
				// Set first responder to avoid keyboard dismissal
				//		addressInput.setIsFirstResponderSignal.value = true
				//	}

				// Also hack for not hiding keyboard during transition

				bag += NotificationCenter.default
					.signal(forName: UIResponder.keyboardWillHideNotification)
					.filter(predicate: { _ in isTransitioningSignal.value })
					.onValue { _ in
						addressInput.setIsFirstResponderSignal.value = true
					}

				bag += addressInput.shouldReturn.set { _ -> Bool in let innerBag = DisposeBag()
					innerBag += addressState.textSignal.atOnce().take(first: 1)
						.onValue { value in complete(value)
							innerBag.dispose()
						}
					return true
				}

				bag += button.onTapSignal.withLatestFrom(addressState.textSignal.atOnce().plain())
					.onFirstValue { _, value in complete(value) }

				return bag
			}
		)
	}
}
