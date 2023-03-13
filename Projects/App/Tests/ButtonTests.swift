import SnapshotTesting
import Testing
import UIKit
import XCTest
import hCore
import hCoreUI
import TestDependencies

@testable import Ugglan

class ButtonTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testChatButton() {
        let chatButton = ChatButton(presentingViewController: UIViewController())

        materializeViewable(chatButton) { view in ciAssertSnapshot(matching: view, as: .image) }
    }
}
