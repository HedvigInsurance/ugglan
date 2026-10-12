@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataPayoutSelectionTests: XCTestCase {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let nordea = PaymentMethod.nordea(bankAccount: .init(account: "3300-1234567", bank: "Nordea"))

    private func makeStatusData(payoutMethods: [ConnectedPaymentMethod]) -> PaymentStatusData {
        .test(defaultPayoutMethod: payoutMethods.first(where: \.isDefault), payoutMethods: payoutMethods)
    }

    // MARK: - activePayoutMethods

    func testActivePayoutMethodsIncludesOnlyActiveMethods() {
        let activeNordea = nordea.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let unknownTrustly = trustly.connected(status: .unknown)
        let statusData = makeStatusData(payoutMethods: [activeNordea, pendingSwish, unknownTrustly])

        XCTAssertEqual(statusData.activePayoutMethods, [activeNordea])
    }

    // MARK: - selectablePayoutMethods

    func testSelectablePayoutMethodsDefaultFirst() {
        let activeTrustly = trustly.connected()
        let defaultSwish = swish.connected(isDefault: true)
        let activeNordea = nordea.connected()
        let statusData = makeStatusData(payoutMethods: [activeTrustly, defaultSwish, activeNordea])

        XCTAssertEqual(statusData.selectablePayoutMethods, [defaultSwish, activeTrustly, activeNordea])
    }

    func testSelectablePayoutMethodsExcludesPendingMethods() {
        let defaultNordea = nordea.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payoutMethods: [pendingSwish, defaultNordea])

        XCTAssertEqual(statusData.selectablePayoutMethods, [defaultNordea])
    }

    func testSelectableMethodsForPayoutIgnoresPayinMethods() {
        let defaultNordea = nordea.connected(isDefault: true)
        let statusData = PaymentStatusData.test(
            payinMethods: [trustly.connected(isDefault: true), swish.connected()],
            payoutMethods: [defaultNordea]
        )

        XCTAssertEqual(statusData.selectableMethods(for: .payout), [defaultNordea])
    }

    // MARK: - canChooseDefaultPayoutMethod

    func testCanChooseDefaultPayoutMethodWithoutMethods() {
        let statusData = makeStatusData(payoutMethods: [])

        XCTAssertFalse(statusData.canChooseDefaultPayoutMethod)
    }

    func testCanChooseDefaultPayoutMethodWithOneActiveMethod() {
        let statusData = makeStatusData(
            payoutMethods: [nordea.connected(isDefault: true), swish.connected(status: .pending)]
        )

        XCTAssertFalse(statusData.canChooseDefaultPayoutMethod)
    }

    func testCanChooseDefaultPayoutMethodWithTwoActiveMethods() {
        let statusData = makeStatusData(
            payoutMethods: [nordea.connected(isDefault: true), swish.connected()]
        )

        XCTAssertTrue(statusData.canChooseDefaultPayoutMethod)
    }
}
