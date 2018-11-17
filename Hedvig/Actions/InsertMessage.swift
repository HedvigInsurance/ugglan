//
//  InsertMessage.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-15.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana

struct InsertMessage: AppAction {
    var globalId: String
    var header: MessageHeader
    var body: MessageBody

    func updatedState(currentState: inout AppState) {
        let newMessage = Message(globalId: globalId, header: header, body: body, isSending: false)
        currentState.messages.insert(newMessage, at: 0)
    }
}
