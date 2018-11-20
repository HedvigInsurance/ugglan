//
//  ChatViewController.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana
import PinLayout
import Tempura

class ChatViewController: ViewControllerWithLocalState<ChatView> {
    let inputFieldView = InputFieldView()
    let wordmarkIocn = Icon(frame: .zero, iconName: "Wordmark", iconWidth: 90)
    let navigationBarBorder = UIView(frame: .zero)
    let navigationBarBlurView = UIVisualEffectView(frame: .zero)
    static let blurEffect = UIBlurEffect(style: .extraLight)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        subscribeToMessages()
    }

    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)

        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.topItem?.titleView = wordmarkIocn
            navigationBar.tintColor = HedvigColors.purple
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()

            navigationBarBlurView.effect = ChatViewController.blurEffect

            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            navigationBarBlurView.frame = navigationBar.bounds.insetBy(
                dx: 0,
                dy: -statusBarHeight
            ).offsetBy(
                dx: 0,
                dy: -statusBarHeight
            )
            navigationBarBlurView.backgroundColor = HedvigColors.white.withAlphaComponent(0.7)

            navigationBar.addSubview(navigationBarBlurView)
            navigationBar.sendSubviewToBack(navigationBarBlurView)
            navigationBarBlurView.contentView.addSubview(navigationBarBorder)

            navigationBarBorder.pin.bottom(1)
            navigationBarBorder.pin.height(1)
            navigationBarBorder.pin.width(navigationBarBlurView.frame.width)
            navigationBarBorder.backgroundColor = HedvigColors.grayBorder
        }
    }

    func loadMessages() {
        HedvigApolloClient.client?.fetch(query: MessagesQuery()) { result, _ in
            if let apolloMessages = result?.data?.messages {
                let messages = apolloMessages.map({ (message) -> Message in
                    Message(fromApollo: message!)
                })

                DispatchQueue.main.async {
                    self.dispatch(SetMessages(messages: messages))
                }
            }
        }
    }

    func subscribeToMessages() {
        HedvigApolloClient.client?.subscribe(subscription: MessageSubscription()) { result, _ in
            if let message = result?.data?.message {
                let stateMessage = Message(fromApollo: message)
                let action = InsertMessage(
                    message: stateMessage
                )

                DispatchQueue.main.async {
                    self.dispatch(action)
                }
            }
        }
    }

    override var inputAccessoryView: UIView? {
        return inputFieldView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}
