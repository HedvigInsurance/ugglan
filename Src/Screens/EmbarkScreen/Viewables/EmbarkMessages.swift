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
}

extension EmbarkMessages: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        let bag = DisposeBag()
        
        let animateOutSignal: Signal = dataSignal.animated(style: .lightBounce(), animations: { _ in
            for (index, stackedMessage) in view.subviews.enumerated() {
                stackedMessage.transform = CGAffineTransform(translationX: 0, y: CGFloat(-70-(1/(index+1))*20))
                stackedMessage.alpha = 0
            }
        })
        
        let delaySignal = Signal(after: 1.5).readable()
        
        bag += combineLatest(dataSignal.compactMap { $0 }.driven(by: animateOutSignal), delaySignal.compactMap { $0 }).onValueDisposePrevious { messages, _ in
            let innerBag = DisposeBag()
           
            innerBag += messages.map({ message -> String? in
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
            }).compactMap { $0 }.map { messageText in
                return view.addArranged(MessageBubble(text: messageText, delay: 0))
            }
            
            for (index, stackedMessage) in view.subviews.enumerated() {
                stackedMessage.transform = CGAffineTransform.identity
                stackedMessage.transform = CGAffineTransform(translationX: 0, y: 40)
                stackedMessage.alpha = 0
               
               innerBag += Signal(after: 0.1+Double(index)*0.1).animated(style: .lightBounce(), animations: { _ in
                   stackedMessage.transform = CGAffineTransform.identity
                   stackedMessage.alpha = 1
               })
           }
            
           return innerBag
        }
        
        return (view, bag)
    }
}
