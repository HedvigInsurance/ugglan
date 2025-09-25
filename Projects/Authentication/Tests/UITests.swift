import XCTest

@MainActor
class UgglanUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @available(iOS 17.0, *)
    func testAppAccessibilityOnLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // This single line performs the accessibility audit.
        try app.performAccessibilityAudit()
    }
}
