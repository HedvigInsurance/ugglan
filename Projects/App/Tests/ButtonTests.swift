import hCore
import hCoreUI
import SnapshotTesting
import Testing
import UIKit
import XCTest

@testable import Ugglan

class ButtonTests: XCTestCase {
	override func setUp() {
		super.setUp()
		setupScreenShotTests()
	}

	func testChatButton() {
		let chatButton = ChatButton(presentingViewController: UIViewController())

		materializeViewable(chatButton) { view in assertSnapshot(matching: view, as: .image) }
	}
}
