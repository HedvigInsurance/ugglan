//
//  SendMessage.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-13.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana

struct SendMessage: AppAction {
    var text: String

    func updatedState(currentState: inout AppState) {
        let newMessage = Message(globalId: "5", fromMyself: true, body: MessageBody(text: text))
        currentState.messages.insert(newMessage, at: currentState.messages.count)
    }
}
