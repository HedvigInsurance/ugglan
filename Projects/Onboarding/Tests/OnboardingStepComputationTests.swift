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
                .phoneNumber(phoneNumber: "", email: ""),
            ]
        )
    }

    func testPhoneNumberStepCarriesContactInfo() {
        let steps = OnboardingStepList.compute(
            contactInfo: .init(email: "demo@hedvig.com", phone: "0735328847")
        )
        XCTAssertTrue(steps.contains(.phoneNumber(phoneNumber: "0735328847", email: "demo@hedvig.com")))
    }
}
