import Flow
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import XCTest
import hCoreUI

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
