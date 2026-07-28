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
                .phoneNumber(phoneNumber: ""),
                .theme,
            ]
        )
    }

    func testPhoneNumberStepCarriesContactInfo() {
        let steps = OnboardingStepList.compute(
            contactInfo: .init(phone: "0735328847")
        )
        XCTAssertTrue(steps.contains(.phoneNumber(phoneNumber: "0735328847")))
    }
}
