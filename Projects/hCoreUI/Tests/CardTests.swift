import Flow
import Form
import Foundation
import SnapshotTesting
import TestDependencies
import Testing
import XCTest
import hCoreUI

@testable import hCoreUI

final class CardTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let card = Card(
            titleIcon: hCoreUIAssets.apartment.image,
            title: "Change address",
            body: "BLAH BLAH BLAH",
            buttonText: "See full update",
            backgroundColor: .brand(.primaryBackground()),
            buttonType: .standardOutline(
                borderColor: .brand(.primaryBorderColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )

        materializeViewable(card) { view in
            view.snp.makeConstraints { make in make.width.equalTo(400) }

            ciAssertSnapshot(matching: view, as: .image)
        }
    }
}
