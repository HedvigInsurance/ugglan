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
        
        bag += dataSignal.atOnce().compactMap { $0 }.onValueDisposePrevious { messages in
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
            }).compactMap { $0 }.enumerated().map { arg in
                let (offset, messageText) = arg
                return view.addArranged(MessageBubble(text: messageText, delay: 0.10 * Double(offset)))
           }
           
           return innerBag
        }
        
        return (view, bag)
    }
}
