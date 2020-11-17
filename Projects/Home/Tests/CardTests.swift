import Flow
import Foundation
import hCoreUI
@testable import Home
import SnapshotTesting
import Testing
import XCTest

final class CardTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testLavenderCard() {
        let card = Card(
            titleIcon: hCoreUIAssets.warningTriangle.image,
            title: "This is a mock card",
            body: "This is the body of that mock card",
            buttonText: "This is a mock button",
            backgroundColor: .tint(.lavenderTwo),
            buttonType: .outline(
                borderColor: .brand(.primaryText()),
                textColor: .brand(.primaryText())
            )
        )

        bag += materializeViewable(card) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
        }.nil()
    }

    func testYellowCard() {
        let card = Card(
            titleIcon: hCoreUIAssets.document.image,
            title: "This is a mock card",
            body: "This is the body of that mock card",
            buttonText: "This is a mock button",
            backgroundColor: .tint(.yellowOne),
            buttonType: .standardSmall(
                backgroundColor: .tint(.yellowTwo),
                textColor: .typographyColor(.primary(state: .matching(.tint(.yellowTwo))))
            )
        )

        bag += materializeViewable(card) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(400)
            }

            assertSnapshot(matching: view, as: .image)
        }.nil()
    }
}
