import XCTest
import hCore

@testable import Onboarding

final class OnboardingStepComputationTests: XCTestCase {
    func testStaticStepsAlwaysPresent() {
        let steps = OnboardingStepList.compute()
        XCTAssertEqual(
            steps,
            [
                .welcome,
                .analyticsConsent,
            ]
        )
    }
}
