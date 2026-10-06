@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataPayinSelectionTests: XCTestCase {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let invoice = PaymentTestMethod.invoice

    private func makeStatusData(payinMethods: [ConnectedPaymentMethod]) -> PaymentStatusData {
        .test(defaultPayinMethod: payinMethods.first(where: \.isDefault), payinMethods: payinMethods)
    }

    // MARK: - activePayinMethods

    func testActivePayinMethodsEmptyWithoutMethods() {
        let statusData = makeStatusData(payinMethods: [])

        XCTAssertEqual(statusData.activePayinMethods, [])
    }

    func testActivePayinMethodsIncludesOnlyActiveMethods() {
        let activeTrustly = trustly.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let unknownInvoice = invoice.connected(status: .unknown)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, unknownInvoice, activeSwish])

        XCTAssertEqual(statusData.activePayinMethods, [activeTrustly, activeSwish])
    }

    // MARK: - selectablePayinMethods

    func testSelectablePayinMethodsDefaultFirst() {
        let activeTrustly = trustly.connected()
        let defaultInvoice = invoice.connected(isDefault: true)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [activeTrustly, defaultInvoice, activeSwish])

        XCTAssertEqual(statusData.selectablePayinMethods, [defaultInvoice, activeTrustly, activeSwish])
    }

    func testSelectablePayinMethodsPreservesBackendOrderWithoutDefault() {
        let activeSwish = swish.connected()
        let activeInvoice = invoice.connected()
        let activeTrustly = trustly.connected()
        let statusData = makeStatusData(payinMethods: [activeSwish, activeInvoice, activeTrustly])

        XCTAssertEqual(statusData.selectablePayinMethods, [activeSwish, activeInvoice, activeTrustly])
    }

    func testSelectablePayinMethodsExcludesPendingMethods() {
        let activeTrustly = trustly.connected()
        let pendingSwish = swish.connected(status: .pending)
        let defaultInvoice = invoice.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, defaultInvoice])

        XCTAssertEqual(statusData.selectablePayinMethods, [defaultInvoice, activeTrustly])
    }

    func testSelectablePayinMethodsExcludesPendingDefault() {
        let pendingDefaultSwish = swish.connected(status: .pending, isDefault: true)
        let activeTrustly = trustly.connected()
        let statusData = makeStatusData(payinMethods: [pendingDefaultSwish, activeTrustly])

        XCTAssertEqual(statusData.selectablePayinMethods, [activeTrustly])
    }

    func testSelectablePayinMethodsEmptyWhenAllPending() {
        let statusData = makeStatusData(
            payinMethods: [swish.connected(status: .pending), trustly.connected(status: .pending)]
        )

        XCTAssertEqual(statusData.selectablePayinMethods, [])
    }

    // MARK: - canChooseDefaultPayinMethod

    func testCanChooseDefaultPayinMethodWithoutMethods() {
        let statusData = makeStatusData(payinMethods: [])

        XCTAssertFalse(statusData.canChooseDefaultPayinMethod)
    }

    func testCanChooseDefaultPayinMethodWithOnlyPendingMethods() {
        let statusData = makeStatusData(
            payinMethods: [swish.connected(status: .pending), trustly.connected(status: .pending)]
        )

        XCTAssertFalse(statusData.canChooseDefaultPayinMethod)
    }

    func testCanChooseDefaultPayinMethodWithOneActiveMethod() {
        let statusData = makeStatusData(
            payinMethods: [trustly.connected(isDefault: true), swish.connected(status: .pending)]
        )

        XCTAssertFalse(statusData.canChooseDefaultPayinMethod)
    }

    func testCanChooseDefaultPayinMethodWithTwoActiveMethods() {
        let statusData = makeStatusData(
            payinMethods: [trustly.connected(isDefault: true), swish.connected()]
        )

        XCTAssertTrue(statusData.canChooseDefaultPayinMethod)
    }
}
