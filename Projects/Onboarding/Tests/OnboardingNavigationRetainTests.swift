@preconcurrency import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingNavigationRetainTests: XCTestCase {
    func testViewModelDeallocatesDespiteItsRouteSubscription() async {
        var vm: OnboardingNavigationViewModel? = OnboardingNavigationViewModel()
        weak let weakVm = vm

        vm = nil
        await delay(0.01)

        XCTAssertNil(weakVm, "the route subscription must not hold the onboarding view model")
    }
}
