//
//  ChatView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit
import Tempura
import PinLayout

class ChatView: UIView, ViewControllerModellableView {
    var listView = ListView()
    
    func setup() {
        listView.messages = model?.messages
        self.addSubview(listView)
    }
    
    func style() {
        self.backgroundColor = UIColor.red
    }
    
    func update(oldModel: ChatViewModel?) {
        listView.messages = model?.messages
    }
    
    override func layoutSubviews() {
        self.pin.height(100%)
        self.pin.width(100%)
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
    
    init?(state: AppState?, localState: ChatLocalState) {
        guard let state = state else { return nil }
        self.messages = state.messages
    }
}
