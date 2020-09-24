import Foundation
import hCoreUI
@testable import Home
import SnapshotTesting
import Testing
import XCTest

final class CardTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testCard() {
        let card = Card(
            titleIcon: hCoreUIAssets.warningTriangle.image,
            title: "This is a mock card",
            body: "This is the body of that mock card",
            buttonText: "This is a mock button"
        )

        materializeViewable(card) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
        }
    }
}
