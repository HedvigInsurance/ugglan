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

struct MessageHeader: Equatable {
    var fromMyself: Bool

    init(fromMyself: Bool) {
        self.fromMyself = fromMyself
    }
}

struct Message: Equatable {
    var globalId: String
    var header: MessageHeader
    var body: MessageBody
    var isSending: Bool

    init(globalId: String, header: MessageHeader, body: MessageBody, isSending: Bool) {
        self.globalId = globalId
        self.header = header
        self.body = body
        self.isSending = isSending
    }

    init(fromApollo message: MessagesQuery.Data.Message) {
        globalId = message.globalId

        let header = MessageHeader(fromMyself: message.header.fromMyself)
        self.header = header

        let body = MessageBody(text: message.body.fragments.messageBodyCoreFragment.text)
        self.body = body

        isSending = false
    }

    init(fromApollo message: MessageSubscription.Data.Message) {
        globalId = message.globalId

        let header = MessageHeader(fromMyself: message.header.fromMyself)
        self.header = header

        let body = MessageBody(text: message.body.fragments.subscriptionMessageBodyCoreFragment.text)
        self.body = body

        isSending = false
    }
}
