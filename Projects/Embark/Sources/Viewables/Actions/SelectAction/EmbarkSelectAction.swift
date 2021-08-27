import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

struct EmbarkSelectAction {
	@PresentableStore var store: EmbarkStateStore
	let data: hSelectAction
	@ReadWriteState private var isSelectOptionLoading = false
}

extension EmbarkSelectAction: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Signal<hEmbarkLink>) {
		let view = UIStackView()
		view.axis = .vertical
		view.spacing = 10

		let bag = DisposeBag()

		return (
			view,
			Signal { callback in let options = self.data.options
				let numberOfStacks =
					options.count % 2 == 0
					? options.count / 2 : Int(floor(Double(options.count) / 2) + 1)

				for iteration in 1...numberOfStacks {
					let stack = UIStackView()
					stack.spacing = 10
					stack.distribution = .fillEqually
					view.addArrangedSubview(stack)

					let optionsSlice = Array(
						options[2 * iteration - 2..<min(2 * iteration, options.count)]
					)
					bag += optionsSlice.map { option in
						let selectActionOption = EmbarkSelectActionOption(
							data: option
						)

						return stack.addArranged(selectActionOption)
							.filter(predicate: { _ in !isSelectOptionLoading })
							.atValue { _ in $isSelectOptionLoading.value = true }
							.mapLatestToFuture {
								result -> Future<
									(hEmbarkLink, ActionResponseData)
								> in
								let defaultLink = option.link
								if let api = option.api {
									selectActionOption.$isLoading.value = true
									store.send(.sendAPI(api: api))
								}

								return Future((defaultLink, result))
							}
							.onValue { link, result in
								result.keys.enumerated()
									.forEach { offset, key in
										let value = result.values[offset]
										store.send(
											.setValue(
												key: key,
												value: value
											)
										)
									}

                                if let passageName = store.state.currentStory.currentPassage?.name
								{
                                    store.send(
                                        .setValue(
                                            key: "\(passageName)Result",
                                            value: result.textValue
                                        )
                                    )
								}

								callback(link)
							}
					}
					if optionsSlice.count < 2, options.count > 1 {
						stack.addArrangedSubview(UIView())
					}
				}

				return bag
			}
		)
	}
}
