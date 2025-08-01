import Flow
import Foundation
import SnapshotTesting
import Testing
import XCTest
import hCore

@testable import Market

final class LanguageSwitcherTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testRendersCorrectOptions() {}
}
