@preconcurrency import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingNavigationRetainTests: XCTestCase {
    /// `routeCountCancellable` is the one place this view model can capture itself: `sink` holds
    /// its closure for as long as the cancellable lives, and the view model owns the cancellable.
    /// Drop the `[weak self]` in `init` and this is the test that notices.
    func testViewModelDeallocatesDespiteItsRouteSubscription() async {
        var vm: OnboardingNavigationViewModel? = OnboardingNavigationViewModel()
        weak let weakVm = vm

        vm = nil
        // The subscription delivers on the main run loop, so let it drain before checking.
        await delay(0.01)

        XCTAssertNil(weakVm, "the route subscription must not hold the onboarding view model")
    }
}
