import Flow
import Foundation
import hCore
import SnapshotTesting
import Testing
import XCTest

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
