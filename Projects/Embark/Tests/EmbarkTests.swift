import Foundation
import XCTest
@testable import Embark
import Testing
import SnapshotTesting

final class EmbarkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_example() {
        // Add your test here
        
        let tooltip = TooltipButton(state: EmbarkState())
        
        materializeViewable(tooltip) { tooltipView in
            assertSnapshot(matching: tooltipView, as: .image)
        }
    }
}
