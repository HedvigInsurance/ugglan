//
//  UITest.swift
//
//
//  Created by Sam Pettersson on 2018-11-10.
//

import XCTest
import TempuraTesting
@testable import Hedvig

class UITest: XCTestCase, UITestCase {
    typealias V = ChatView
    
    var firstTestViewModel: ChatViewModel {
        return ChatViewModel(messages: [
                Message(globalId: "1", fromMyself: true, body: MessageBody(text: "testing")),
            Message(globalId: "2", fromMyself: false, body: MessageBody(text: "testing a longer message")),
            Message(globalId: "3", fromMyself: true, body: MessageBody(text: "testing a longer message"))
        ])
    }
    
    func testChatScreen() {
        var context = UITests.Context<ChatView>()
        context.container = .navigationController
        
        self.uiTest(testCases: [
            "chatView001": firstTestViewModel
            ], context: context)
    }
}
