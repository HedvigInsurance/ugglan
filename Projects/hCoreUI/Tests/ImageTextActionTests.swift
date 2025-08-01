import Flow
import Form
import Foundation
import SnapshotTesting
import TestDependencies
import Testing
import XCTest

@testable import hCoreUI

final class ImageTextActionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: hCoreUIAssets.wordmark.image),
            title: "mock",
            body: "a long body",
            actions: [
                (
                    (),
                    Button(
                        title: "I am a button",
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                )
            ],
            showLogo: false
        )

        let viewController = UIViewController()
        let bag = DisposeBag()

        bag += viewController.install(imageTextAction).nil()

        ciAssertSnapshot(matching: viewController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testWithLogo() {
        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: hCoreUIAssets.wordmark.image),
            title: "mock",
            body: "a long body",
            actions: [
                (
                    (),
                    Button(
                        title: "I am a button",
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                )
            ],
            showLogo: true
        )

        let viewController = UIViewController()
        let bag = DisposeBag()

        bag += viewController.install(imageTextAction).nil()

        ciAssertSnapshot(matching: viewController, as: .image(on: .iPhoneX))

        bag.dispose()
    }
}
