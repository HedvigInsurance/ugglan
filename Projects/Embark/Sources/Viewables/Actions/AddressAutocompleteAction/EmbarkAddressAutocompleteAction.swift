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
	let state: EmbarkState
	let data: EmbarkAddressAutocompleteData

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
		//let animator = ViewableAnimator(state: .notLoading, handler: self, views: AnimatorViews())
		//animator.register(key: \.view, value: view)

		let bag = DisposeBag()

		let box = UIControl()
		//box.backgroundColor = .brand(.secondaryBackground())
		box.backgroundColor = .brand(.primaryButtonBackgroundColor)
		box.layer.cornerRadius = 8
		bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }
		//animator.register(key: \.box, value: box)
        view.addArrangedSubview(box)
        
        let addressInput = AddressInput(placeholder: data.addressAutocompleteActionData.placeholder)
        addressInput.textSignal.value = prefillValue
        bag += box.add(addressInput) { addressInputView in
            addressInputView.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
        }

		let button = Button(
			title: data.addressAutocompleteActionData.link.fragments.embarkLinkFragment.label,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += view.addArranged(button)
		//{ buttonView in animator.register(key: \.button, value: buttonView) }

        bag += addressInput.textSignal.atOnce().map { text in !text.isEmpty }
			.bindTo(button.isEnabled)

		return (
			view,
			Signal { callback in
				func complete(_ value: String) {
					if let passageName = self.state.passageNameSignal.value {
						self.state.store.setValue(key: "\(passageName)Result", value: value)
					}

					//let unmaskedValue = self.masking?.unmaskedValue(text: value) ?? value
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

				bag += box.signal(for: .touchUpInside)
					.onValue { _ in
                        let autocompleteView = EmbarkAddressAutocomplete(
                            state: self.state,
                            data: self.data
                        )
                        
                        box.viewController?
							.present(
								autocompleteView,
                                style: .address(view: box)
                            ).onValue { _ in
                                print("FRAME FINISHED PRES")
                            }
						// Set first responder to avoid keyboard dismissal
						addressInput.setIsFirstResponderSignal.value = true
					}

				// Also hack for not hiding keyboard during transition
				bag += NotificationCenter.default
					.signal(forName: UIResponder.keyboardWillHideNotification)
					.onValue { _ in
						addressInput.setIsFirstResponderSignal.value = true
					}

				bag += addressInput.shouldReturn.set { _ -> Bool in let innerBag = DisposeBag()
                    innerBag += addressInput.textSignal.atOnce().take(first: 1)
						.onValue { value in complete(value)
							innerBag.dispose()
						}
					return true
				}

                bag += button.onTapSignal.withLatestFrom(addressInput.textSignal.atOnce().plain())
					.onFirstValue { _, value in complete(value) }

				return bag
			}
		)
	}
}
