//
//  ChatViewTest.swift
//
//
//  Created by Sam Pettersson on 2018-11-10.
//

import XCTest
import TempuraTesting
import Katana
@testable import Hedvig

class ChatViewTest: XCTestCase, UITestCase {
    typealias V = ChatView
    
    let store = Store<AppState>(middleware: [], dependencies: DependenciesContainer.self)
    
    var chatViewModel: ChatViewModel {
        return ChatViewModel(messages: [
            Message(
                globalId: "1",
                fromMyself: true,
                body: MessageBody(text: "testing")
            ),
            Message(
                globalId: "2",
                fromMyself: false,
                body: MessageBody(text: "testing a longer message")
            ),
            Message(
                globalId: "3",
                fromMyself: true,
                body: MessageBody(text: "testing a longer message")
            )
        ])
    }
    
    func testChatScreen() {
        self.uiTest(testCases: [
            "chatView001": chatViewModel
        ])
    }
}
