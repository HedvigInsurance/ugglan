import Payment
import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingConnectPaymentStepTests: XCTestCase {
    func testMarkPaymentConnectedFlipsOnlyTheConnectPaymentStep() {
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.welcome, .connectPayment(connectedProvider: nil), .theme]

        vm.markPaymentConnected(provider: .trustly)

        XCTAssertEqual(
            vm.steps,
            [.welcome, .connectPayment(connectedProvider: .trustly), .theme]
        )
    }

    func testAdvanceAfterConnectPaymentMovesOnWhateverTheFlagSays() {
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.connectPayment(connectedProvider: nil), .theme]

        vm.advance(after: .connectPayment(connectedProvider: .trustly))

        XCTAssertEqual(vm.router.routeTypes.count, 1)
    }
}
