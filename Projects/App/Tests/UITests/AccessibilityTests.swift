import XCTest

@available(iOS 17.0, *)
@MainActor
class AccessibilityTests: XCTestCase {
    let XCUIAccessibilityAuditIssuesKey = "XCUIAccessibilityAuditIssuesKey"

    //    func testContrastIssuesIgnoringHPill() throws {
    //        let app = XCUIApplication()
    //        app.launchArguments = ["-UITestExcludeHPill"]
    //        app.launch()
    //
    //        do {
    //            try app.performAccessibilityAudit(for: [.contrast])
    //        } catch {
    //            // Log the failure but note that hPill may be included
    //            print("Contrast audit failed (ignoring known hPill false positives): \(error)")
    //        }
    //    }

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

    func testVoiceOverHealth() throws {
        let app = XCUIApplication()
        app.launch()

        // Get all elements on the screen
        let allElements = app.descendants(matching: .any).allElementsBoundByIndex
        var totalElements = 0
        var failedElements = 0

        for element in allElements {
            if element.isAccessibilityElement {
                totalElements += 1
                var failed = false

                // 1. Must have a label
                if element.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    XCTFail("Missing accessibility label on element: \(element)")
                    failed = true
                }

                // 2. Must have traits
                if element.accessibilityTraits.isEmpty {
                    XCTFail("Missing accessibility traits on element: \(element)")
                    failed = true
                }

                // 3. Tap target size check
                let frame = element.frame
                if frame.width < 44 || frame.height < 44 {
                    XCTFail("Tap target too small for element: \(element), size: \(frame.size)")
                    failed = true
                }

                if failed {
                    failedElements += 1
                }
            }
        }

        // Calculate a simple health score
        let healthScore = totalElements == 0 ? 100 : 100 - (Double(failedElements) / Double(totalElements) * 100)
        print("VoiceOver Accessibility Health Score: \(healthScore)%")
        XCTAssert(healthScore >= 85, "VoiceOver accessibility health is below threshold")
    }
}
