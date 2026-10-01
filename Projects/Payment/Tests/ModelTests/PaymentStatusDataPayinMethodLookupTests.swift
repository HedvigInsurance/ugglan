@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataPayinMethodLookupTests: XCTestCase {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let invoice = PaymentTestMethod.invoice

    private func makeStatusData(
        defaultPayinMethod: ConnectedPaymentMethod? = nil,
        payinMethods: [ConnectedPaymentMethod]
    ) -> PaymentStatusData {
        .test(defaultPayinMethod: defaultPayinMethod, payinMethods: payinMethods)
    }

    func testPayinMethodWithoutMethodsReturnsNil() {
        let statusData = makeStatusData(payinMethods: [])

        XCTAssertNil(statusData.connectedPaymentMethod(for: .swish))
    }

    func testPayinMethodWithoutMatchingProviderReturnsNil() {
        let statusData = makeStatusData(
            defaultPayinMethod: trustly.connected(isDefault: true),
            payinMethods: [trustly.connected(isDefault: true), invoice.connected(status: .pending)]
        )

        XCTAssertNil(statusData.connectedPaymentMethod(for: .swish))
    }

    func testPayinMethodActiveMatchNotProcessing() throws {
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [trustly.connected(isDefault: true), activeSwish])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, activeSwish)
    }

    func testPayinMethodPendingMatchIsProcessing() throws {
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payinMethods: [trustly.connected(isDefault: true), pendingSwish])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, pendingSwish)
    }

    func testPayinMethodPrefersActiveOverPendingMatch() throws {
        let pendingSwish = swish.connected(status: .pending)
        let activeSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [pendingSwish, activeSwish])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, activeSwish)
    }

    func testPayinMethodFallsBackToFirstMatchWithoutActive() throws {
        let unknownSwish = swish.connected(status: .unknown)
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payinMethods: [unknownSwish, pendingSwish])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, unknownSwish)
    }

    func testPayinMethodOtherProviderPendingNotProcessing() throws {
        let activeTrustly = trustly.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, swish.connected(status: .pending)])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .trustly))

        XCTAssertEqual(result, activeTrustly)
    }

    func testPayinMethodMatchOnlyInDefaultPayinMethod() throws {
        let defaultSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(defaultPayinMethod: defaultSwish, payinMethods: [trustly.connected()])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, defaultSwish)
    }

    func testPayinMethodPrefersActiveListedMethodOverPendingDefault() throws {
        let pendingDefaultSwish = swish.connected(status: .pending, isDefault: true)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(defaultPayinMethod: pendingDefaultSwish, payinMethods: [activeSwish])

        let result = try XCTUnwrap(statusData.connectedPaymentMethod(for: .swish))

        XCTAssertEqual(result, activeSwish)
    }

    func testDefaultOrFirstDefaultFallsBackToTheListWithoutADefaultField() {
        let activeTrustly = trustly.connected()
        let defaultSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, defaultSwish])

        XCTAssertEqual(statusData.defaultOrFirstDefaultPayinMethod, defaultSwish)
    }
}
