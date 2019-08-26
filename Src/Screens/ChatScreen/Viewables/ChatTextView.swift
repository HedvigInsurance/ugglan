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
    let currentGlobalIdSignal: ReadSignal<GraphQLID?>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)

    private let didBeginEditingCallbacker = Callbacker<Void>()

    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }

    init(
        currentGlobalIdSignal: ReadSignal<GraphQLID?>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.currentGlobalIdSignal = currentGlobalIdSignal
        self.client = client
    }
}

extension ChatTextView: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let textView = TextView(
            value: "",
            placeholder: "Aa",
            insets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 40)
        )
        let (view, result) = textView.materialize(events: events)

        let bag = DisposeBag()

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
