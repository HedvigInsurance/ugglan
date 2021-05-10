import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

typealias EmbarkNumberActionSetData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberActionSet
	.Datum

typealias EmbarkTextActionSetData = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet
	.TextActionSetDatum

struct EmbarkNumberActionSet {
	let state: EmbarkState
	let data: EmbarkNumberActionSetData
}

struct EmbarkActionSetInputData {
	internal init(
		numberActionSet: EmbarkNumberActionSetData,
		state: EmbarkState
	) {
		actions = numberActionSet.numberActions.map { numberAction in
			.init(
				placeholder: numberAction.data?.placeholder,
				key: numberAction.data?.key,
				mask: .digits,
				title: numberAction.data?.title
			)
		}
		link = numberActionSet.link.fragments.embarkLinkFragment
		self.state = state
	}

	internal init(
		textActionSet: EmbarkTextActionSetData,
		state: EmbarkState
	) {
		actions = textActionSet.textActions.map { textAction in
			.init(
				placeholder: textAction.data?.placeholder,
				key: textAction.data?.key,
				mask: MaskType(rawValue: textAction.data?.mask ?? "None"),
				title: textAction.data?.title
			)
		}
		link = textActionSet.link.fragments.embarkLinkFragment
		self.state = state
	}

	struct Action {
		var placeholder: String?
		var key: String?
		var mask: MaskType?
		var title: String?
	}

	var actions: [Action]
	var link: GraphQL.EmbarkLinkFragment
	let state: EmbarkState
}

extension EmbarkActionSetInputData: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
		let view = UIStackView()
		view.axis = .vertical
		view.spacing = 10
		let bag = DisposeBag()

		let boxStack = UIStackView()
		boxStack.axis = .vertical
		boxStack.spacing = 20
		boxStack.edgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)

		let containerView = UIView()
		containerView.backgroundColor = .brand(.secondaryBackground())
		containerView.layer.cornerRadius = 8

		func getMasking(_ action: Action) -> Masking? {
			guard let mask = action.mask else { return nil }

			return Masking(type: mask)
		}

		let actionSignals = actions.enumerated()
			.map {
				index,
				action -> (
					signal: ReadWriteSignal<String>, shouldReturn: Delegate<String, Bool>,
					action: Action
				) in let endIndex = actions.endIndex
				let isLastAction: Bool = index == endIndex - 1

				let masking = getMasking(action)

				let input = EmbarkInput(
					placeholder: action.placeholder ?? "",
					keyboardType: masking?.keyboardType,
					textContentType: masking?.textContentType,
					returnKeyType: isLastAction ? .done : .next,
					autocapitalisationType: masking?.autocapitalizationType ?? .words,
					masking: masking ?? Masking(type: .none),
					shouldAutoFocus: index == 0,
					fieldStyle: .embarkInputSmall,
					textFieldAlignment: .right
				)

				let label = UILabel(value: action.title ?? "", style: .brand(.body(color: .primary)))

				let stack = UIStackView()
				stack.axis = .horizontal
				stack.distribution = .equalSpacing

				stack.addArrangedSubview(label)

				boxStack.addArrangedSubview(stack)

				if !isLastAction, endIndex > 0 {
					let divider = Divider(backgroundColor: .brand(.primaryBorderColor))
					bag += boxStack.addArranged(divider)
				}

				var prefillValue: String {
					guard let key = action.key, let value = state.store.getPrefillValue(key: key)
					else { return "" }

					if let masking = masking { return masking.maskValueFromStore(text: value) }

					return value
				}

				let textSignal = stack.addArranged(input)
				textSignal.value = prefillValue

				return (signal: textSignal, shouldReturn: input.shouldReturn, action: action)
			}

		return (
			view,
			Signal { callback in
				func complete() {
					actionSignals.forEach { signal, _, action in
						self.state.store.setValue(key: action.key, value: signal.value)
					}

					if let passageName = self.state.passageNameSignal.value {
						self.state.store.setValue(
							key: "\(passageName)Result",
							value: actionSignals.map { $0.signal.value }
								.joined(separator: " ")
						)
					}

					callback(link)
				}

				containerView.addSubview(boxStack)
				boxStack.snp.makeConstraints { make in make.edges.equalToSuperview() }

				view.addArrangedSubview(containerView)

				let button = Button(
					title: link.label,
					type: .standard(
						backgroundColor: .brand(.secondaryButtonBackgroundColor),
						textColor: .brand(.secondaryButtonTextColor)
					),
					isEnabled: false
				)

				bag += view.addArranged(button)

				func isValid(signal: ReadWriteSignal<String>, action: Action) -> Signal<Bool> {
					signal.atOnce()
						.map { text in
							!text.isEmpty
								&& (getMasking(action)?.isValid(text: text) ?? true)
						}
						.plain()
				}

				bag += actionSignals.map { _, shouldReturn, _ in shouldReturn }.enumerated()
					.map { offset, shouldReturn in
						shouldReturn.set { value -> Bool in
							if !value.isEmpty {
								if offset == actionSignals.count - 1 { complete() }

								return true
							}

							return false
						}
					}

				bag += combineLatest(
					actionSignals.map { signal, _, action in isValid(signal: signal, action: action)
					}
				)
				.map { !$0.contains(false) }.bindTo(button.isEnabled)

				bag += containerView.applyShadow { (_) -> UIView.ShadowProperties in .embark }

				bag += view.chainAllControlResponders()

				bag += button.onTapSignal.onValue { _ in complete() }

				return bag
			}
		)
	}
}
