//
//  InputFieldView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import DynamicColor
import Foundation
import PinLayout
import Tempura
import UIKit

class InputFieldView: UIView, View, UITextViewDelegate {
    var textView = UITextView()
    var sendButton: SendButton!
    var currentChatResponse: CurrentChatResponseSubscription.Data.CurrentChatResponse?
    var safeAreaContainer = SafeAreaContainer()
    var selectCollectionView = SelectCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func subscribeToCurrentResponse() {
        HedvigApolloClient.client?.subscribe(subscription: CurrentChatResponseSubscription()) { result, _ in
            self.currentChatResponse = result?.data?.currentChatResponse
            self.update()
        }
    }

    func setup() {
        selectCollectionView.alpha = 0
        selectCollectionView.transform = CGAffineTransform(
            translationX: 0,
            y: -selectCollectionView.frame.height
        )

        subscribeToCurrentResponse()
        sendButton = SendButton(frame: .zero, onSend: onShouldSend)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        textView.addSubview(sendButton)
        textView.delegate = self

        safeAreaContainer.safeAreaContainer.addSubview(textView)
        safeAreaContainer.safeAreaContainer.addSubview(selectCollectionView)
        addSubview(safeAreaContainer)

        selectCollectionView.onSelect = onSelect

        handleButtonState()
    }

    func style() {
        textView.backgroundColor = HedvigColors.white.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 20
        textView.layer.borderColor = HedvigColors.grayBorder.cgColor
        textView.layer.borderWidth = 1
        textView.font = HedvigFonts.circularStdBook?.withSize(15)
        textView.tintColor = HedvigColors.purple
    }

    func update() {
        if let currentChatResponse = self.currentChatResponse {
            if let choices = currentChatResponse.body?.fragments.messageBodySingleSelectFragment?.choices {
                UIView.animate(withDuration: 0.25) {
                    self.textView.alpha = 0
                    self.selectCollectionView.alpha = 1
                    self.selectCollectionView.transform = CGAffineTransform.identity
                }
                selectCollectionView.choices = choices
                selectCollectionView.update()
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.textView.alpha = 1
                    self.selectCollectionView.alpha = 0
                    self.selectCollectionView.transform = CGAffineTransform(
                        translationX: 0,
                        y: -self.selectCollectionView.frame.height
                    )
                }
                selectCollectionView.choices = []
                selectCollectionView.update()
            }
        }
    }

    override func layoutSubviews() {
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 35)
        textView.pin.width(95%)
        textView.pin.height(max(textView.contentSize.height, 40))
        textView.pin.top(10)
        textView.pin.left(2.5%)
        sendButton.pin.bottom(5)
        sendButton.pin.right(5)
        sendButton.pin.sizeToFit()
        selectCollectionView.pin.top(0)
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    func handleButtonState() {
        if textView.text.count == 0 {
            sendButton.activated = false
        } else {
            sendButton.activated = true
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        safeAreaContainer.heightDidChange(height: max(textView.contentSize.height + 20, 60))
        textView.setContentOffset(CGPoint.zero, animated: false)

        layoutIfNeeded()

        handleButtonState()
    }

    func onShouldSend() {
        if let globalId = self.currentChatResponse?.globalId {
            let body = ChatResponseBodyTextInput(text: String(textView.text))
            let input = ChatResponseTextInput(globalId: globalId, body: body)
            HedvigApolloClient.client?.perform(mutation: SendChatTextResponseMutation(input: input))
        }

        textView.text = ""
        handleButtonState()
        textViewDidChange(textView)
    }

    func onSelect(_ choice: MessageBodySingleSelectFragment.Choice?) {
        if let globalId = self.currentChatResponse?.globalId {
            if let choiceValue = choice?
                .fragments
                .messageBodyChoicesSelectionFragment?
                .fragments
                .messageBodyChoicesCoreFragment.value {
                let body = ChatResponseBodySingleSelectInput(selectedValue: choiceValue)
                let input = ChatResponseSingleSelectInput(globalId: globalId, body: body)
                let mutation = SendChatSingleSelectResponseMutation(input: input)
                HedvigApolloClient.client?.perform(mutation: mutation)
            }
        }
    }
}
