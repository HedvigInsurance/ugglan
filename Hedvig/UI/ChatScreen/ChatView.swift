//
//  ChatView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class ChatView: UIView, ViewControllerModellableView {
    var listView = ListView()

    func setup() {
        if let navigationBarHeight = self.viewController?.navigationController?.navigationBar.frame.height {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            listView.navigationBarHeight = navigationBarHeight + statusBarHeight
        }

        listView.messages = model?.messages
        addSubview(listView)
    }

    func style() {
        backgroundColor = UIColor.red
    }

    func update(oldModel _: ChatViewModel?) {
        if model?.messages.count != 0 {
            listView.messages = model?.messages
            listView.update()
        }
    }

    override func layoutSubviews() {
        pin.height(100%)
        pin.width(100%)
    }
}

struct ChatLocalState: LocalState {
    var input: String = ""
}

struct ChatViewModel: ViewModelWithLocalState, Equatable {
    var messages: [Message]

    init(messages: [Message]) {
        self.messages = messages
    }

    init?(state: AppState?, localState _: ChatLocalState) {
        guard let state = state else { return nil }
        messages = state.messages
    }
}
