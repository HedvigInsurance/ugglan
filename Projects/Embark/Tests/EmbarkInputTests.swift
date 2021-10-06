import Foundation
import SnapshotTesting
import Testing
import XCTest

@testable import Embark

final class EmbarkInputTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testInput() {
        let embarkInput = EmbarkInput(placeholder: "Test 123", autocapitalisationType: .words)

        materializeViewable(embarkInput) { tooltipView in
            tooltipView.snp.makeConstraints { make in make.width.equalTo(300) }
            assertSnapshot(matching: tooltipView, as: .image)
        }
    }
}
