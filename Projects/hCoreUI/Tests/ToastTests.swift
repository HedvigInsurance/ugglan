import Form
import Foundation
import SnapshotTesting
import TestDependencies
import Testing
import XCTest

@testable import hCoreUI

final class ToastTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let toast = Toast(symbol: .none, body: "Testing a title!")

        materializeViewable(toast) { view in
            view.snp.makeConstraints { make in make.width.equalTo(400) }

            ciAssertSnapshot(matching: view, as: .image)
        }
    }
}
