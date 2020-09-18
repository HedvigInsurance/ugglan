import Flow
import Foundation
import hCore
import hGraphQL
import UIKit

struct EmbarkMessages {
    let state: EmbarkState
}

extension EmbarkMessages: Viewable {
    func parseMessage(message: GraphQL.MessageFragment) -> String? {
        if message.expressions.isEmpty {
            return message.text
        }

        let firstMatchingExpression = message.expressions.first { expression -> Bool in
            self.state.store.passes(expression: expression)
        }

        if firstMatchingExpression == nil {
            return nil
        }

        if let multipleExpression =
            firstMatchingExpression?.fragments.expressionFragment.asEmbarkExpressionMultiple {
            return multipleExpression.text
        }

        if let binaryExpression =
            firstMatchingExpression?
                .fragments
                .expressionFragment
                .fragments
                .basicExpressionFragment
                .asEmbarkExpressionBinary {
            return binaryExpression.text
        }

        if let unaryExpression =
            firstMatchingExpression?
                .fragments
                .expressionFragment
                .fragments
                .basicExpressionFragment
                .asEmbarkExpressionUnary {
            return unaryExpression.text
        }

        return nil
    }

    func replacePlaceholders(message: String) -> String {
        let placeholderRegex = "(\\{[a-zA-Z0-9_.]+\\})"

        do {
            let regex = try NSRegularExpression(pattern: placeholderRegex)
            let results = regex.matches(in: message, range: NSRange(message.startIndex..., in: message))
            let stringResults = results.map {
                String(message[Range($0.range, in: message)!])
            }
            var replacedMessage = message
            stringResults.forEach { message in
                let key = message.replacingOccurrences(of: "[\\{\\}]", with: "", options: [.regularExpression])
                let result = self.state.store.getValue(key: key)
                replacedMessage = replacedMessage.replacingOccurrences(of: message, with: result ?? key)
            }

            return replacedMessage
        } catch {
            return message
        }
    }

    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        let bag = DisposeBag()

        let previousResponseSignal: ReadWriteSignal<(
            response: GraphQL.ResponseFragment?,
            passageName: String?
        )?> = ReadWriteSignal(nil)

        let messagesDataSignal = state.currentPassageSignal.map { $0?.messages }
        let responseDataSignal = state.currentPassageSignal.map { $0?.response.fragments.responseFragment }

        let animatedResponseSignal: Signal = messagesDataSignal.withLatestFrom(previousResponseSignal).animated(style: .lightBounce(), animations: { _, previousResponse in
            if self.state.animationDirectionSignal.value == .forwards {
                if let singleMessage = previousResponse?.response?.asEmbarkMessage {
                    let msgText = self.parseMessage(message: singleMessage.fragments.messageFragment)
                    let responseText = self.replacePlaceholders(message: msgText ?? "")

                    let messageBubble = MessageBubble(text: responseText, delay: 0, animated: true, messageType: .replied)
                    bag += view.addArranged(messageBubble)
                } else if let passageName = previousResponse?.passageName {
                    let responseText = self.replacePlaceholders(message: "{\(passageName)Result}")
                    let messageBubble = MessageBubble(text: responseText, delay: 0, animated: true, messageType: .replied)
                    bag += view.addArranged(messageBubble)
                }
            }
            previousResponseSignal.value = (responseDataSignal.value, self.state.passageNameSignal.value)
        })

        let animateOutSignal: Signal = animatedResponseSignal.animated(style: .lightBounce(), animations: { _ in
            for (index, stackedMessage) in view.subviews.enumerated() {
                stackedMessage.transform = CGAffineTransform(translationX: 0, y: CGFloat(-90 - (1 / (index + 1)) * 20))
                stackedMessage.alpha = 0
            }
        })

        let delaySignal = Signal(after: 1.5).readable()

        bag += combineLatest(messagesDataSignal.compactMap { $0 }.driven(by: animateOutSignal), delaySignal.compactMap { $0 }).onValueDisposePrevious { messages, _ in
            let innerBag = DisposeBag()

            for stackedView in view.subviews {
                stackedView.removeFromSuperview()
            }

            innerBag += messages.map { self.parseMessage(message: $0.fragments.messageFragment) }.compactMap { $0 }.enumerated().map { (arg) -> Disposable in
                let (index, messageText) = arg
                let text = self.replacePlaceholders(message: messageText)
                return view.addArranged(MessageBubble(text: text, delay: 0, animated: true, animationDelay: TimeInterval(index)))
            }

            return innerBag
        }

        return (view, bag)
    }
}
