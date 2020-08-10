//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import hCore
import hCoreUI
import SnapshotTesting
import Testing
@testable import Ugglan
import UIKit
import XCTest

class ButtonTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testChatButton() {
        let chatButton = ChatButton(presentingViewController: UIViewController())

        materializeViewable(chatButton) { view in
            assertSnapshot(matching: view, as: .image)
        }
    }
}
