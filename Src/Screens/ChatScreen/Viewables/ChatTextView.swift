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
import Common
import ComponentKit

struct ChatTextView {
    @Inject var client: ApolloClient
    let chatState: ChatState
    let isHiddenSignal = ReadWriteSignal<Bool>(false)

    private let didBeginEditingCallbacker = Callbacker<Void>()

    var didBeginEditingSignal: Signal<Void> {
        return didBeginEditingCallbacker.providedSignal
    }

    init(
        chatState: ChatState
    ) {
        self.chatState = chatState
    }
}

extension ChatTextView: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let defaultPlaceholder = "Aa"

        let textView = TextView(
            placeholder: defaultPlaceholder,
            insets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 40)
        )
        let (view, value) = textView.materialize(events: events)

        let bag = DisposeBag()

        bag += chatState.currentMessageSignal.atOnce().compactMap { $0 }.onValue { message in
            textView.keyboardTypeSignal.value = message.keyboardType
            textView.placeholder.value = message.placeholder ?? defaultPlaceholder
        }

        bag += value.onValue { _ in
            if let message = self.chatState.currentMessageSignal.value {
                switch message.responseType {
                case .text:
                    break
                case .none, .singleSelect, .audio:
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
            buttonView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(5)
                make.right.equalToSuperview().inset(5)
            }
        }.withLatestFrom(value.plain()).onValue { _, textFieldValue in
            value.value = ""
            bag += self.chatState.sendChatFreeTextResponse(text: textFieldValue).onValue { _ in }
        }

        return (view, bag)
    }
}
