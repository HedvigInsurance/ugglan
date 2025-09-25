import XCTest

@available(iOS 17.0, *)
@MainActor
class AccessibilityTests: XCTestCase {

    func testContrastIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.contrast])
        } catch {
            XCTFail("Contrast audit failed with error: \(error)")
        }
    }

    func testDynamicTypeIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.dynamicType])
        } catch {
            XCTFail("Dynamic Type audit failed with error: \(error)")
        }
    }

    func testElementDetectionIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.elementDetection])
        } catch {
            XCTFail("Element Detection audit failed with error: \(error)")
        }
    }

    func testHitRegionIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.hitRegion])
        } catch {
            XCTFail("Hit Region audit failed with error: \(error)")
        }
    }

    func testSufficientElementDescriptionIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.sufficientElementDescription])
        } catch {
            XCTFail("Sufficient Element Description audit failed with error: \(error)")
        }
    }

    func testTextClippedDescriptionIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.textClipped])
        } catch {
            XCTFail("Text Clipped audit failed with error: \(error)")
        }
    }

    func testTraitIssues() throws {
        let app = XCUIApplication()
        app.launch()

        do {
            try app.performAccessibilityAudit(for: [.trait])
        } catch {
            XCTFail("Trait audit failed with error: \(error)")
        }
    }
}
