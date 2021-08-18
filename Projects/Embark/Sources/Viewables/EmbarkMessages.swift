import Flow
import Foundation
import UIKit
import hCore
import hGraphQL

struct EmbarkMessages { let state: EmbarkState }

extension EmbarkMessages: Viewable {
	func parseMessage(message: GraphQL.MessageFragment) -> String? {
		if message.expressions.isEmpty { return message.text }

		return parse(message.expressions.map { $0.fragments.expressionFragment })
	}

	func parse(_ expressions: [GraphQL.ExpressionFragment]) -> String? {
		guard
			let expression = expressions.first(where: { fragment in
				self.state.store.passes(expression: fragment)
			})
		else { return nil }

		if let multipleExpression = expression.asEmbarkExpressionMultiple { return multipleExpression.text }

		if let binaryExpression = expression.fragments.basicExpressionFragment.asEmbarkExpressionBinary {
			return binaryExpression.text
		}

		if let unaryExpression = expression.fragments.basicExpressionFragment.asEmbarkExpressionUnary {
			return unaryExpression.text
		}

		return nil
	}

	func replacePlaceholders(message: String) -> String {
		if let stringResults = getPlaceHolders(message: message) {
			var replacedMessage = message
			stringResults.forEach { message in
				let key = message.replacingOccurrences(
					of: "[\\{\\}]",
					with: "",
					options: [.regularExpression]
				)
				let result = self.state.store.getValue(key: key)
				replacedMessage = replacedMessage.replacingOccurrences(of: message, with: result ?? key)
			}

			return replacedMessage
		} else {
			return message
		}
	}

	func replacePlaceholdersForMultiAction(message: String, values: [MultiActionStoreable]) -> String {
		if let stringResults = getPlaceHolders(message: message) {
			var replacedMessage = message
			stringResults.forEach { placeholder in
				let key = placeholder.replacingOccurrences(
					of: "[\\{\\}]",
					with: "",
					options: [.regularExpression]
				)

				let result = values.first(where: { $0.componentKey == key })?.inputValue
				replacedMessage = replacedMessage.replacingOccurrences(of: message, with: result ?? key)
			}

			return replacedMessage
		} else {
			return message
		}
	}

	func getPlaceHolders(message: String) -> [String]? {
		let placeholderRegex = "(\\{[a-zA-Z0-9_.]+\\})"
		let regex = try? NSRegularExpression(pattern: placeholderRegex)
		let results = regex?.matches(in: message, range: NSRange(message.startIndex..., in: message))
		let stringResults = results?.compactMap { String(message[Range($0.range, in: message)!]) }
		return stringResults
	}

	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let view = UIStackView()
		view.axis = .vertical
		view.alignment = .top
		view.spacing = 10
		let bag = DisposeBag()

		bag += state.edgePanGestureRecognizer?.signal(forState: .changed)
			.onValue { _ in
				guard let viewController = view.viewController,
					let edgePanGestureRecognizer = state.edgePanGestureRecognizer
				else { return }

				let percentage =
					edgePanGestureRecognizer.translation(in: viewController.view).x
					/ viewController.view.frame.width

				view.transform = CGAffineTransform(
					translationX: 0,
					y: -view.frame.height * (percentage * 2.5)
				)
			}

		bag += state.edgePanGestureRecognizer?.signal(forState: .ended)
			.animated(style: .heavyBounce()) { view.transform = CGAffineTransform(translationX: 0, y: 0) }

		let previousResponseSignal:
			ReadWriteSignal<(response: GraphQL.ResponseFragment?, passageName: String?)?> = ReadWriteSignal(
				nil
			)

		let messagesDataSignal = state.currentPassageSignal.map { $0?.messages }
		let responseDataSignal = state.currentPassageSignal.map { $0?.response.fragments.responseFragment }

		func mapItems(item: GraphQL.ResponseFragment.AsEmbarkGroupedResponse.Item) -> String {
			let msgText = parse(item.expressions.map { $0.fragments.expressionFragment })
			let responseText = replacePlaceholders(message: msgText ?? item.text)
			return responseText
		}

		func configureEach(each: GraphQL.ResponseFragment.AsEmbarkGroupedResponse.Each?) -> [String] {
			guard let each = each else { return [] }
			let msgText = parse(each.content.expressions.map { $0.fragments.expressionFragment })
			let storeItems = state.store.getMultiActionItems(actionKey: each.key)
			let dictionary = Dictionary(grouping: storeItems, by: { $0.index })
			let msgs = dictionary.map { _, values in
				replacePlaceholdersForMultiAction(message: msgText ?? each.content.text, values: values)
			}
			return msgs
		}

		let animatedResponseSignal: Signal = messagesDataSignal.withLatestFrom(previousResponseSignal)
			.animated(
				style: .lightBounce(),
				animations: { _, previousResponse in
					if self.state.animationDirectionSignal.value == .forwards {
						let passageName = previousResponse?.passageName ?? ""
						let autoResponseKey = "\(passageName)Result"

						if let singleMessage = previousResponse?.response?.asEmbarkMessage {
							let msgText = self.parseMessage(
								message: singleMessage.fragments.messageFragment
							)
							let responseText = self.replacePlaceholders(
								message: msgText ?? ""
							)

							if responseText != autoResponseKey {
								let messageBubble = MessageBubble(
									text: responseText,
									delay: 0,
									animated: true,
									messageType: .replied
								)
								bag += view.addArranged(messageBubble)
							}
						} else if let embarkResponseExpression = previousResponse?.response?
							.asEmbarkResponseExpression
						{
							let msgText = self.parse(
								embarkResponseExpression.expressions.map {
									$0.fragments.expressionFragment
								}
							)
							let responseText = self.replacePlaceholders(
								message: msgText ?? embarkResponseExpression.text
							)

							if responseText != autoResponseKey {
								let messageBubble = MessageBubble(
									text: responseText,
									delay: 0,
									animated: true,
									messageType: .replied
								)
								bag += view.addArranged(messageBubble)
							}
						} else if let embarkGroupedResponse = previousResponse?.response?
							.asEmbarkGroupedResponse
						{
							let itemPills = embarkGroupedResponse.items.map { item in
								mapItems(item: item)
							}
							let eachPills = configureEach(each: embarkGroupedResponse.each)

							let messageBubble = MessageBubble(
								text: embarkGroupedResponse.title.text,
								delay: 0,
								animated: true,
								messageType: .replied,
								pills: itemPills + eachPills
							)
							bag += view.addArranged(messageBubble)
						} else {
							let responseText = self.replacePlaceholders(
								message: "{\(autoResponseKey)}"
							)

							if responseText != autoResponseKey {
								let messageBubble = MessageBubble(
									text: responseText,
									delay: 0,
									animated: true,
									messageType: .replied
								)
								bag += view.addArranged(messageBubble)
							}
						}
					}
					previousResponseSignal.value = (
						responseDataSignal.value, self.state.passageNameSignal.value
					)
				}
			)

		let animateOutSignal: Signal = animatedResponseSignal.animated(
			style: .lightBounce(),
			animations: { _ in
				for (index, stackedMessage) in view.subviews.enumerated() {
					stackedMessage.transform = CGAffineTransform(
						translationX: 0,
						y: CGFloat(-90 - (1 / (index + 1)) * 20)
					)
					stackedMessage.alpha = 0
				}
			}
		)

		bag += messagesDataSignal.compactMap { $0 }.driven(by: animateOutSignal)
			.onValueDisposePrevious { messages in let innerBag = DisposeBag()

				for stackedView in view.subviews { stackedView.removeFromSuperview() }

				innerBag += messages.map { self.parseMessage(message: $0.fragments.messageFragment) }
					.compactMap { $0 }.enumerated()
					.map { (arg) -> Disposable in let (index, messageText) = arg
						let text = self.replacePlaceholders(message: messageText)
						return view.addArranged(
							MessageBubble(
								text: text,
								delay: 0,
								animated: true,
								animationDelay: TimeInterval(index * 2)
							)
						)
					}

				return innerBag
			}

		return (view, bag)
	}
}
