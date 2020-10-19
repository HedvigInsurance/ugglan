import Flow
import Form
import Foundation
@testable import Payment
import SnapshotTesting
import Testing
import XCTest

final class DirectDebitResultTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testSuccess() {
        let directDebitResult = DirectDebitResult(type: .success(setupType: .postOnboarding))

        let viewController = UIViewController()
        let bag = DisposeBag()

        bag += viewController.install(directDebitResult)

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testFailure() {
        let directDebitResult = DirectDebitResult(type: .failure(setupType: .postOnboarding))

        let viewController = UIViewController()
        let bag = DisposeBag()

        bag += viewController.install(directDebitResult)

        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX))

        bag.dispose()
    }
}
