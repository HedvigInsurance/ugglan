import Flow
import Foundation
import hCoreUI
import SnapshotTesting
import SwiftUI
import Testing
import XCTest

@testable import Contracts

final class CrossSellingItemScreenshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testScreenshot() {
        assertSnapshot(
            matching: CrossSellingItemPreviews.itemWithoutImage,
            as: .image(layout: .device(config: .iPhoneX))
        )
    }
}
