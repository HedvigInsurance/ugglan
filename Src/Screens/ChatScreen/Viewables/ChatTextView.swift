//
//  ChatTextView.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-25.
//

import Apollo
import Flow
import Foundation
import UIKit

struct ChatTextView {
    let client: ApolloClient
    let currentMessageSignal: ReadSignal<Message?>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)

    private let didBeginEditingCallbacker = Callbacker<Void>()

    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }

    init(
        currentMessageSignal: ReadSignal<Message?>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.currentMessageSignal = currentMessageSignal
        self.client = client
    }
}

extension ChatTextView: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let defaultPlaceholder = "Aa"
        
        let textView = TextView(
            value: "",
            placeholder: defaultPlaceholder,
            insets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 40)
        )
        let (view, result) = textView.materialize(events: events)
        
        let bag = DisposeBag()
        
        bag += currentMessageSignal.atOnce().compactMap { $0 }.onValue { message in
            textView.keyboardTypeSignal.value = message.keyboardType
            textView.textContentTypeSignal.value = message.textContentType
            textView.placeholder.value = message.placeholder ?? defaultPlaceholder
        }
        
        bag += textView.value.onValue { _ in
            if let message = self.currentMessageSignal.value {
                switch message.responseType {
                case .text:
                    break
                case .none, .singleSelect:
                    bag += Signal(after: 0).feedback(type: .error)
                }
            }
        }

        bag += textView.didBeginEditingSignal.onValue { _ in
            self.didBeginEditingCallbacker.callAll()
        }

        bag += isHiddenSignal.animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
            view.animationSafeIsHidden = isHidden
        }

        bag += view.add(SendButton()) { buttonView in
            buttonView.snp.makeConstraints({ make in
                make.bottom.equalToSuperview().inset(5)
                make.right.equalToSuperview().inset(5)
            })
        }.withLatestFrom(textView.value.plain()).onValue({ _, textFieldValue in
            textView.value.value = ""
            if let currentGlobalId = self.currentMessageSignal.value?.globalId, textFieldValue != "" {
                bag += self.client.perform(mutation: SendChatTextResponseMutation(globalId: currentGlobalId, text: textFieldValue))
            }
        })

        return (view, Disposer {
            bag.dispose()
            result.dispose()
        })
    }
}
