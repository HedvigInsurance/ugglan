//
//  MessageBubbleTests.swift
//  EmbarkTests
//
//  Created by sam on 26.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import XCTest
@testable import Embark
import Testing
import SnapshotTesting

final class MessageBubbleTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }
    
    func testMessage() {
        let messageBubble = MessageBubble(text: "Hello, I am a message 👋", delay: 0)
        
        materializeViewable(messageBubble) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(200)
            }
            
            assertSnapshot(matching: view, as: .image)
        }
    }
    
    func testAnotherMessage() {
        let messageBubble = MessageBubble(text: "Hello, I am also a message but a bit of a longer one", delay: 0)
        
        materializeViewable(messageBubble) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(200)
            }
            
            assertSnapshot(matching: view, as: .image)
        }
    }
}
