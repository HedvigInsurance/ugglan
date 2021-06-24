import Flow
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct Action { let state: EmbarkState }

struct ActionResponse {
	let link: GraphQL.EmbarkLinkFragment
	let data: ActionResponseData
}

struct ActionResponseData {
	let keys: [String]
	let values: [String]
	let textValue: String
}

extension Action: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<GraphQL.EmbarkLinkFragment>) {
		let bag = DisposeBag()

		let outerContainer = UIStackView()
		outerContainer.axis = .vertical
		outerContainer.alignment = .center

		bag += state.edgePanGestureRecognizer?.signal(forState: .changed)
			.onValue { _ in
				guard let viewController = outerContainer.viewController,
					let edgePanGestureRecognizer = state.edgePanGestureRecognizer
				else { return }

				let percentage =
					edgePanGestureRecognizer.translation(in: viewController.view).x
					/ viewController.view.frame.width

				outerContainer.transform = CGAffineTransform(
					translationX: 0,
					y: outerContainer.frame.height * (percentage * 2.5)
				)
			}

		bag += state.edgePanGestureRecognizer?.signal(forState: .ended)
			.animated(style: .heavyBounce()) {
				outerContainer.transform = CGAffineTransform(translationX: 0, y: 0)
			}

		let widthContainer = UIStackView()
		widthContainer.axis = .horizontal
		outerContainer.addArrangedSubview(widthContainer)

		bag += outerContainer.didLayoutSignal.onValue { _ in
			widthContainer.snp.remakeConstraints { make in
				if outerContainer.traitCollection.horizontalSizeClass == .regular,
					outerContainer.traitCollection.userInterfaceIdiom == .pad
				{
					make.width.equalTo(
						outerContainer.frame.width > 600 ? 600 : outerContainer.frame.width
					)
				} else {
					make.width.equalTo(outerContainer.frame.width)
				}
			}
		}

		let view = UIStackView()
		view.axis = .horizontal
		widthContainer.addArrangedSubview(view)

		let actionDataSignal = state.currentPassageSignal.map { $0?.action }

		let isHiddenSignal = ReadWriteSignal(true)

		func handleViewState(_ isHidden: Bool) {
			let extraPadding: CGFloat = 40
			let viewHeight =
				view.systemLayoutSizeFitting(.zero).height
				+ (view.viewController?.view.safeAreaInsets.bottom ?? 0) + extraPadding
			view.transform =
				isHidden
				? CGAffineTransform(translationX: 0, y: viewHeight) : CGAffineTransform.identity
		}

		bag += view.didLayoutSignal.withLatestFrom(isHiddenSignal.atOnce().plain())
			.map { _, isHidden in isHidden }.onValue(handleViewState)
		bag += isHiddenSignal.atOnce().onValue(handleViewState)

		let animationStyle = SpringAnimationStyle(
			duration: 0.5,
			damping: 100,
			velocity: 0.8,
			delay: 0,
			options: [.allowUserInteraction]
		)

		let hideAnimationSignal = actionDataSignal.withLatestFrom(state.passageNameSignal)
			.animated(style: animationStyle) { _, _ in isHiddenSignal.value = true
				view.firstPossibleResponder?.resignFirstResponder()
				view.layoutIfNeeded()
			}
			.delay(by: 0)

		bag += hideAnimationSignal.delay(by: 0.25)
			.animated(style: animationStyle) { _ in isHiddenSignal.value = false
				view.layoutIfNeeded()
			}

		return (
			outerContainer,
			Signal { callback in
				let shouldUpdateUISignal = actionDataSignal.flatMapLatest { _ in
					hideAnimationSignal.map { _ in true }.readable(initial: false)
				}

				bag += actionDataSignal.withLatestFrom(self.state.passageNameSignal)
					.wait(until: shouldUpdateUISignal)
					.onValueDisposePrevious { actionData, _ in let innerBag = DisposeBag()

						let hasCallbackedSignal = ReadWriteSignal<Bool>(false)

						func performCallback(_ link: GraphQL.EmbarkLinkFragment) {
							if !hasCallbackedSignal.value {
								hasCallbackedSignal.value = true
								callback(link)
							}
						}

						if let selectAction = actionData?.asEmbarkSelectAction {
							innerBag +=
								view.addArranged(
									EmbarkSelectAction(
										state: self.state,
										data: selectAction
									)
								)
								.onValue(performCallback)
                        } else if let dateAction = actionData?.asEmbarkDatePickerAction {
                            innerBag += view.addArranged(EmbarkDatePickerAction(state: self.state, data: dateAction)).onValue(performCallback)
                        } else if let textAction = actionData?.asEmbarkTextAction {
							innerBag +=
								view.addArranged(
									EmbarkTextAction(
										state: self.state,
										data: textAction
									)
								)
								.onValue(performCallback)
						} else if let numberAction = actionData?.asEmbarkNumberAction {
							innerBag +=
								view.addArranged(
									EmbarkNumberAction(
										state: self.state,
										data: numberAction
									)
								)
								.onValue(performCallback)
						} else if let numberActionSetData = actionData?.asEmbarkNumberActionSet?
							.data
						{
							let inputSet = EmbarkActionSetInputData(
								numberActionSet: numberActionSetData,
								state: self.state
							)
							innerBag += view.addArranged(inputSet).onValue(performCallback)
						} else if let textActionSet = actionData?.asEmbarkTextActionSet?
							.textActionSetData
						{
							let inputSet = EmbarkActionSetInputData(
								textActionSet: textActionSet,
								state: self.state
							)
							innerBag += view.addArranged(inputSet).onValue(performCallback)
						} else if let externalInsuranceProviderAction = actionData?
							.asEmbarkExternalInsuranceProviderAction
						{
							innerBag +=
								view.addArranged(
									InsuranceProviderAction(
										state: self.state,
										data: .external(
											externalInsuranceProviderAction
										)
									)
								)
								.onValue(performCallback)
						} else if let previousInsuranceProviderAction = actionData?
							.asEmbarkPreviousInsuranceProviderAction
						{
							innerBag +=
								view.addArranged(
									InsuranceProviderAction(
										state: self.state,
										data: .previous(
											previousInsuranceProviderAction
										)
									)
								)
								.onValue(performCallback)
						}

						return innerBag
					}

				return bag
			}
		)
	}
}
