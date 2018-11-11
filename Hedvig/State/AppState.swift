//
//  AppState.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana

struct AppState: State {
    var messages: [Message] = [
        Message(globalId: "123", fromMyself: true, body: MessageBody(text: "hej mitt namn är sam bla bla hej jag är fisk hej hej hehe")),
        Message(globalId: "123", fromMyself: true, body: MessageBody(text: "hej mitt namn är sam bla bla hej jag är fisk hej hej hehe")),
        Message(globalId: "123", fromMyself: false, body: MessageBody(text: "hej mitt namn är sam bla bla hej jag är fisk hej hej hehe")),
        Message(globalId: "123", fromMyself: true, body: MessageBody(text: "hej mitt namn är sam bla bla hej jag är fisk hej hej hehe")),
        Message(globalId: "123", fromMyself: true, body: MessageBody(text: "hej mitt namn är sam bla bla hej jag är fisk hej hej hehe"))
    ]
}

