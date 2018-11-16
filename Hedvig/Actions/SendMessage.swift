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
        let globalId = UUID().uuidString
        let header = MessageHeader(fromMyself: true)
        let body = MessageBody(text: text)

        let newMessage = Message(globalId: globalId, header: header, body: body, isSending: true)
        currentState.messages.insert(newMessage, at: currentState.messages.count)
    }
}
