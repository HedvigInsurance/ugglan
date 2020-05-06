//
//  EmbarkMessages.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import UIKit

struct EmbarkMessages {
    let store: EmbarkStore
    let dataSignal: ReadSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage.Message]?>
    let responseSignal: ReadSignal<ResponseFragment?>
    let goBackSignal: ReadWriteSignal<Bool>
}

extension EmbarkMessages: Viewable {
    func parseMessage(message: MessageFragment) -> String? {
        if message.expressions.count == 0 {
            return message.text
        }
        
        let firstMatchingExpression = message.expressions.first { expression -> Bool in
            self.store.passes(expression: expression)
        }
        
        if firstMatchingExpression == nil {
            return nil
        }
        
        if let multipleExpression = firstMatchingExpression?.fragments.expressionFragment.asEmbarkExpressionMultiple {
            return multipleExpression.text
        }
        
        if let binaryExpression = firstMatchingExpression?.fragments.expressionFragment.fragments.basicExpressionFragment.asEmbarkExpressionBinary {
            return binaryExpression.text
        }
        
        if let unaryExpression = firstMatchingExpression?.fragments.expressionFragment.fragments.basicExpressionFragment.asEmbarkExpressionUnary {
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
                let result = store.store[key]
                replacedMessage = replacedMessage.replacingOccurrences(of: message, with: result ?? key)
            }
            
            return replacedMessage
        } catch {
            return message
        }
    }
    
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        let bag = DisposeBag()
        
        let previousResponseSignal: ReadWriteSignal<ResponseFragment?> = ReadWriteSignal(nil)
        
        let animatedResponseSignal: Signal = dataSignal.withLatestFrom(previousResponseSignal).animated(style: .lightBounce(), animations: { _, previousResponse in
            if self.goBackSignal.value == false {
                if let singleMessage = previousResponse?.asEmbarkMessage {
                    let msgText = self.parseMessage(message: singleMessage.fragments.messageFragment)
                    let responseText = self.replacePlaceholders(message: msgText ?? "")
                    
                    let messageBubble = MessageBubble(text: responseText, delay: 0, animated: true, messageType: .replied)
                    bag += view.addArranged(messageBubble)
                }
            }
            previousResponseSignal.value = self.responseSignal.value
        })
        
        let animateOutSignal: Signal = animatedResponseSignal.animated(style: .lightBounce(), animations: { _ in
            for (index, stackedMessage) in view.subviews.enumerated() {
                stackedMessage.transform = CGAffineTransform(translationX: 0, y: CGFloat(-90-(1/(index+1))*20))
                stackedMessage.alpha = 0
            }
        })
        
        let delaySignal = Signal(after: 1.5).readable()
        
        bag += combineLatest(dataSignal.compactMap { $0 }.driven(by: animateOutSignal), delaySignal.compactMap { $0 }).onValueDisposePrevious { messages, _ in
            let innerBag = DisposeBag()
            
            for stackedView in view.subviews {
                stackedView.removeFromSuperview()
            }
           
            innerBag += messages.map { self.parseMessage(message: $0.fragments.messageFragment) }.compactMap { $0 }.enumerated().map { (arg) -> Disposable in
                let (index, messageText) = arg
                
                return view.addArranged(MessageBubble(text: messageText, delay: 0, animated: true, animationDelay: TimeInterval(index)))
            }
            
            if self.goBackSignal.value == true {
                self.goBackSignal.value = false
            }
            
            /*for (index, stackedMessage) in view.subviews.enumerated() {
                stackedMessage.transform = CGAffineTransform.identity
                stackedMessage.transform = CGAffineTransform(translationX: 0, y: 40)
                stackedMessage.alpha = 0
               
                innerBag += Signal(after: 0.1+Double(index)*0.1).animated(style: .lightBounce(), animations: { _ in
                    stackedMessage.transform = CGAffineTransform.identity
                    stackedMessage.alpha = 1
                })
           }*/
            
           return innerBag
        }
        
        return (view, bag)
    }
}
