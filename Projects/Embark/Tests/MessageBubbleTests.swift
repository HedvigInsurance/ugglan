import Foundation
import SnapshotTesting
import Testing
import XCTest

@testable import Embark

final class MessageBubbleTests: XCTestCase {
  override func setUp() {
    super.setUp()
    setupScreenShotTests()
  }

  func testMessage() {
    let messageBubble = MessageBubble(text: "Hello, I am a message 👋", delay: 0)

    materializeViewable(messageBubble) { view in
      view.snp.makeConstraints { make in make.width.equalTo(200) }

      assertSnapshot(matching: view, as: .image)
    }
  }

  func testAnotherMessage() {
    let messageBubble = MessageBubble(
      text: "Hello, I am also a message but a bit of a longer one",
      delay: 0
    )

    materializeViewable(messageBubble) { view in
      view.snp.makeConstraints { make in make.width.equalTo(200) }

      assertSnapshot(matching: view, as: .image)
    }
  }
}
