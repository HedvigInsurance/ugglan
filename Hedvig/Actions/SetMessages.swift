//
//  InsertMessages.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-15.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana

struct SetMessages: AppAction {
    var messages: [Message]

    func updatedState(currentState: inout AppState) {
        currentState.messages = messages
    }
}
