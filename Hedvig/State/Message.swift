//
//  Message.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-10.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation

struct MessageBody: Equatable {
    var text: String

    init(text: String) {
        self.text = text
    }
}

struct Message: Equatable {
    var globalId: String
    var fromMyself: Bool
    var body: MessageBody

    init(globalId: String, fromMyself: Bool, body: MessageBody) {
        self.globalId = globalId
        self.fromMyself = fromMyself
        self.body = body
    }
}
