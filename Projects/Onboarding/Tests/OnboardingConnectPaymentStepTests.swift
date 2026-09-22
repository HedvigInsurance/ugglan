import Payment
import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingConnectPaymentStepTests: XCTestCase {
    func testMarkPaymentConnectedFlipsOnlyTheConnectPaymentStep() {
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.welcome, .connectPayment(isConnected: false, paymentProvider: nil), .theme]

        vm.markPaymentConnected(provider: .trustly)

        XCTAssertEqual(
            vm.steps,
            [.welcome, .connectPayment(isConnected: true, paymentProvider: .trustly), .theme]
        )
    }

    func testAdvanceAfterConnectPaymentMovesOnWhateverTheFlagSays() {
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.connectPayment(isConnected: false, paymentProvider: nil), .theme]

        vm.advance(after: .connectPayment(isConnected: true, paymentProvider: .trustly))

        XCTAssertEqual(vm.router.routeTypes.count, 1)
    }
}
