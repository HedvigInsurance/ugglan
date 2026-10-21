import Payment
import Testing
import hCore

@testable import Onboarding

extension OnboardingDependencySuite {
    @MainActor
    final class OnboardingConnectPaymentStepTests {
        @Test
        func markPaymentConnectedFlipsOnlyTheConnectPaymentStep() {
            let vm = OnboardingNavigationViewModel()
            vm.steps = [.welcome, .connectPayment(connectedProvider: nil), .theme]

            vm.markPaymentConnected(provider: .trustly)

            #expect(vm.steps == [.welcome, .connectPayment(connectedProvider: .trustly), .theme])
        }

        @Test
        func advanceAfterConnectPaymentMovesOnWhateverTheFlagSays() {
            let vm = OnboardingNavigationViewModel()
            vm.steps = [.connectPayment(connectedProvider: nil), .theme]

            vm.advance(after: .connectPayment(connectedProvider: .trustly))

            #expect(vm.router.routeTypes.count == 1)
        }
    }
}
