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

	private func clearStoreValues() {
		AddressStoreKeys.allCases.forEach { key in
			state.store.setValue(key: key.rawValue, value: "")
		}
	}

	private func getValueFor(key: AddressStoreKeys) -> String? {
		let value = state.store.getValue(key: key.rawValue)
		if value == "" {
			return nil
		} else {
			return value
		}
	}

	var addressFromStore: AddressSuggestion? {
		let suggestion = AddressSuggestion(
			id: getValueFor(key: .id),
			address: getValueFor(key: .address) ?? "",
			streetName: getValueFor(key: .streetName),
			streetNumber: getValueFor(key: .streetNumber),
			floor: getValueFor(key: .floor),
			apartment: getValueFor(key: .apartment),
			postalCode: getValueFor(key: .zipCode),
			city: getValueFor(key: .city)
		)

		if addressState.isComplete(suggestion: suggestion) {
			return suggestion
		} else {
			return nil
		}
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

		addressState.confirmedSuggestionSignal.value = addressFromStore
		addressState.pickedSuggestionSignal.value = addressFromStore
		addressState.textSignal.value = addressState.formatAddressLine(from: addressFromStore)
		//addressState.textSignal.value = prefillValue

		bag += box.add(addressInput) { addressInputView in
			addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		}
		bag += box.didMoveToWindowSignal.delay(by: 0.5)
			.onValue { _ in addressInput.setIsFirstResponderSignal.value = true }

		let touchSignal = box.signal(for: .touchUpInside).readable()
		let typeSignal = addressState.textSignal.latestTwo().filter { $0.1.count - $0.0.count == 1 }.toVoid()
			.readable()

		let button = Button(
			title: data.addressAutocompleteActionData.link.fragments.embarkLinkFragment.label,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += view.addArranged(button)

		bag += addressState.confirmedSuggestionSignal.atOnce().map { suggestion in suggestion != nil }
			.bindTo(button.isEnabled)

		return (
			view,
			Signal { callback in
				func complete(_ selection: AddressSuggestion) {
					let addressLine = addressState.formatAddressLine(from: selection)
					guard let selectionDict = selection.toDict() else {
						completeWithoutAddress()
						return
					}

					clearStoreValues()
					for (key, value) in selectionDict {
						print(key.rawValue)
						self.state.store.setValue(key: key.rawValue, value: value)
					}

					if let passageName = self.state.passageNameSignal.value {
						self.state.store.setValue(
							key: "\(passageName)Result",
							value: addressLine
						)
					}

					self.state.store.setValue(
						key: self.data.addressAutocompleteActionData.key,
						value: addressLine
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

				func completeWithoutAddress() {
					clearStoreValues()
					self.state.store.setValue(
						key: AddressStoreKeys.addressSearchTerm.rawValue,
						value: addressState.textSignal.value
					)

					self.state.store.setValue(
						key: self.data.addressAutocompleteActionData.key,
						value: "ADDRESS_NOT_FOUND"
					)

					callback(
						self.data.addressAutocompleteActionData.link.fragments
							.embarkLinkFragment
					)
				}

				// Also hack for not hiding keyboard during transition
				bag += NotificationCenter.default
					.signal(forName: UIResponder.keyboardWillHideNotification)
					.filter(predicate: { _ in isTransitioningSignal.value })
					.onValue { _ in
						addressInput.setIsFirstResponderSignal.value = true
					}

				bag += addressInput.shouldReturn.set { _ -> Bool in let innerBag = DisposeBag()
					innerBag += addressState.confirmedSuggestionSignal.atOnce().take(first: 1)
						.compactMap { $0 }
						.onValue { value in
							complete(value)
							innerBag.dispose()
						}
					return true
				}

				bag += button.onTapSignal
					.withLatestFrom(addressState.confirmedSuggestionSignal.atOnce().plain())
					.compactMap { $0.1 }
					.onFirstValue { value in complete(value) }

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

						bag += transition.didEndTransitionSignal.onValue { presenting in
							if presenting {
								autocompleteView.setIsFirstResponderSignal.value = true
							} else {
								addressInput.setIsFirstResponderSignal.value = true
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
							.onError { error in
								// Didn't find no address
								isTransitioningSignal.value = false
								if let error = error as? AddressAutocompleteError,
									error == .cantFindAddress
								{
									completeWithoutAddress()
								}
							}
						return bag
					}

				return bag
			}
		)
	}
}
