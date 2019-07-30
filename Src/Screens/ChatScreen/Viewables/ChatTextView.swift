//
//  ChatTextView.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-25.
//

import Foundation
import UIKit
import Flow
import Apollo

struct ChatTextView {
    let client: ApolloClient
    let currentGlobalIdSignal: ReadSignal<GraphQLID?>
    
    private let didBeginEditingCallbacker = Callbacker<Void>()
    
    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }
    
    init(currentGlobalIdSignal: ReadSignal<GraphQLID?>, client: ApolloClient = ApolloContainer.shared.client) {
        self.currentGlobalIdSignal = currentGlobalIdSignal
        self.client = client
    }
}

extension ChatTextView: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let textView = TextView(value: "", placeholder: "Aa")
        let (view, result) = textView.materialize(events: events)
        
        let bag = DisposeBag()
        
        bag += textView.didBeginEditingSignal.onValue { _ in
            self.didBeginEditingCallbacker.callAll()
        }
        
        bag += view.add(SendButton()) { buttonView in
            buttonView.snp.makeConstraints({ make in
                make.bottom.equalToSuperview().inset(5)
                make.right.equalToSuperview().inset(5)
            })
            }.withLatestFrom(textView.value.plain()).onValue({ _, textFieldValue in
                textView.value.value = ""
                if let currentGlobalId = self.currentGlobalIdSignal.value, textFieldValue != "" {
                    bag += self.client.perform(mutation: SendChatTextResponseMutation(globalId: currentGlobalId, text: textFieldValue))
                }
            })
        
        return (view, Disposer {
            bag.dispose()
            result.dispose()
        })
    }
}
