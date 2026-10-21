import Testing
import hCore

@testable import Onboarding

extension OnboardingDependencySuite {
    @MainActor
    final class OnboardingNavigationRetainTests {
        @Test
        func viewModelDeallocatesDespiteItsRouteSubscription() async {
            var vm: OnboardingNavigationViewModel? = OnboardingNavigationViewModel()
            weak let weakVm = vm

            vm = nil
            await delay(0.01)

            #expect(weakVm == nil, "the route subscription must not hold the onboarding view model")
        }
    }
}
