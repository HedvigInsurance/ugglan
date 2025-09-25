import XCTest

@MainActor
class UgglanUITests: XCTestCase {

    func testAppAccessibilityOnLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        if #available(iOS 17.0, *) {
            try app.performAccessibilityAudit()
        }
    }
}
