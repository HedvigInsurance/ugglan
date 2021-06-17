import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkTextActionData = EmbarkPassage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
	let state: EmbarkState
	let data: EmbarkTextActionData

	var masking: Masking? {
		if let mask = data.textActionData.mask, let maskType = MaskType(rawValue: mask) {
			return Masking(type: maskType)
		}

		return nil
	}

	var prefillValue: String {
		guard let value = state.store.getPrefillValue(key: data.textActionData.key) else { return "" }

		if let masking = masking { return masking.maskValueFromStore(text: value) }

		return value
	}
}

extension EmbarkTextAction: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
		let view = UIStackView()
		view.axis = .vertical
		view.spacing = 10
		let animator = ViewableAnimator(state: .notLoading, handler: self, views: AnimatorViews())
		animator.register(key: \.view, value: view)

		let bag = DisposeBag()

		let box = UIView()
		box.backgroundColor = .brand(.secondaryBackground())
		box.layer.cornerRadius = 8
		bag += box.applyShadow { _ -> UIView.ShadowProperties in .embark }
		animator.register(key: \.box, value: box)

		let boxStack = UIStackView()
		boxStack.axis = .vertical
		boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		boxStack.isLayoutMarginsRelativeArrangement = true
		animator.register(key: \.boxStack, value: boxStack)

		box.addSubview(boxStack)
		boxStack.snp.makeConstraints { make in make.top.bottom.right.left.equalToSuperview() }
		view.addArrangedSubview(box)

		let input = EmbarkInput(
			placeholder: data.textActionData.placeholder,
			keyboardType: masking?.keyboardType,
			textContentType: masking?.textContentType,
			autocapitalisationType: masking?.autocapitalizationType ?? .none,
			masking: masking ?? Masking(type: .none),
			shouldAutoSize: true
		)
		let textSignal = boxStack.addArranged(input) { inputView in
			animator.register(key: \.input, value: inputView)
		}
		textSignal.value = prefillValue

		let button = Button(
			title: data.textActionData.link.fragments.embarkLinkFragment.label,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += view.addArranged(button) { buttonView in animator.register(key: \.button, value: buttonView) }

		bag += textSignal.atOnce().map { text in !text.isEmpty && (masking?.isValid(text: text) ?? true) }
			.bindTo(button.isEnabled)

		return (
			view,
			Signal { callback in
				func complete(_ value: String) {
					if let passageName = self.state.passageNameSignal.value {
						self.state.store.setValue(key: "\(passageName)Result", value: value)
					}

					let unmaskedValue = self.masking?.unmaskedValue(text: value) ?? value
					self.state.store.setValue(
						key: self.data.textActionData.key,
						value: unmaskedValue
					)

					if let derivedValues = self.masking?.derivedValues(text: value) {
						derivedValues.forEach { key, value in
							self.state.store.setValue(
								key: "\(self.data.textActionData.key)\(key)",
								value: value
							)
						}
					}

					self.state.store.createRevision()

					if let apiFragment = self.data.textActionData.api?.fragments.apiFragment {
						bag += animator.setState(.loading).filter(predicate: { $0 })
							.mapLatestToFuture { _ in
								self.state.handleApi(apiFragment: apiFragment)
							}
							.onValue { link in guard let link = link else { return }
								callback(link)
							}
					} else {
						callback(self.data.textActionData.link.fragments.embarkLinkFragment)
					}
				}

				bag += input.shouldReturn.set { _ -> Bool in let innerBag = DisposeBag()
					innerBag += textSignal.atOnce().take(first: 1)
						.onValue { value in complete(value)
							innerBag.dispose()
						}
					return true
				}

				bag += button.onTapSignal.withLatestFrom(textSignal.atOnce().plain())
					.onFirstValue { _, value in complete(value) }

				return bag
			}
		)
	}
}

extension Masking {
	func maskValueFromStore(text: String) -> String {
		switch type {
		case .personalNumber, .postalCode, .birthDate, .norwegianPostalCode, .email, .digits,
			.norwegianPersonalNumber, .danishPersonalNumber, .none:
			return maskValue(text: text, previousText: "")
		case .birthDateReverse:
			let reverseDateFormatter = DateFormatter()
			reverseDateFormatter.dateFormat = "yyyy-MM-dd"

			guard let date = reverseDateFormatter.date(from: text) else { return text }

			let birthDateFormatter = DateFormatter()
			birthDateFormatter.dateFormat = "dd-MM-yyyy"

			return maskValue(text: birthDateFormatter.string(from: date), previousText: "")
		}
	}
}
