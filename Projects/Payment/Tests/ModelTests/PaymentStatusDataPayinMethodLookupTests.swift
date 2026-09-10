@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataPayinMethodLookupTests: XCTestCase {
    private let trustly = PaymentMethod.trustly(bankAccount: .init(account: "1234", bank: "Bank"))
    private let swish = PaymentMethod.swish(phoneNumber: "0735328847")
    private let invoice = PaymentMethod.invoice(delivery: .kivra)

    private func makeMethod(
        _ method: PaymentMethod,
        status: PaymentMethodStatus = .active,
        isDefault: Bool = false
    ) -> ConnectedPaymentMethod {
        .init(status: status, isDefault: isDefault, method: method)
    }

    private func makeStatusData(
        defaultPayinMethod: ConnectedPaymentMethod? = nil,
        payinMethods: [ConnectedPaymentMethod]
    ) -> PaymentStatusData {
        .init(
            status: .active,
            chargingDay: 27,
            defaultPayinMethod: defaultPayinMethod,
            payinMethods: payinMethods,
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: nil,
            layout: .other
        )
    }

    func testPayinMethodWithoutMethodsReturnsNil() {
        let statusData = makeStatusData(payinMethods: [])

        XCTAssertNil(statusData.payinMethod(for: .swish))
    }

    func testPayinMethodWithoutMatchingProviderReturnsNil() {
        let statusData = makeStatusData(
            defaultPayinMethod: makeMethod(trustly, isDefault: true),
            payinMethods: [makeMethod(trustly, isDefault: true), makeMethod(invoice, status: .pending)]
        )

        XCTAssertNil(statusData.payinMethod(for: .swish))
    }

    func testPayinMethodActiveMatchNotProcessing() throws {
        let activeSwish = makeMethod(swish)
        let statusData = makeStatusData(payinMethods: [makeMethod(trustly, isDefault: true), activeSwish])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, activeSwish)
        XCTAssertFalse(result.isProcessing)
    }

    func testPayinMethodPendingMatchIsProcessing() throws {
        let pendingSwish = makeMethod(swish, status: .pending)
        let statusData = makeStatusData(payinMethods: [makeMethod(trustly, isDefault: true), pendingSwish])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, pendingSwish)
        XCTAssertTrue(result.isProcessing)
    }

    func testPayinMethodPrefersActiveOverPendingMatch() throws {
        let pendingSwish = makeMethod(swish, status: .pending)
        let activeSwish = makeMethod(swish, isDefault: true)
        let statusData = makeStatusData(payinMethods: [pendingSwish, activeSwish])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, activeSwish)
        XCTAssertTrue(result.isProcessing)
    }

    func testPayinMethodFallsBackToFirstMatchWithoutActive() throws {
        let unknownSwish = makeMethod(swish, status: .unknown)
        let pendingSwish = makeMethod(swish, status: .pending)
        let statusData = makeStatusData(payinMethods: [unknownSwish, pendingSwish])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, unknownSwish)
        XCTAssertTrue(result.isProcessing)
    }

    func testPayinMethodOtherProviderPendingNotProcessing() throws {
        let activeTrustly = makeMethod(trustly, isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, makeMethod(swish, status: .pending)])

        let result = try XCTUnwrap(statusData.payinMethod(for: .trustly))

        XCTAssertEqual(result.method, activeTrustly)
        XCTAssertFalse(result.isProcessing)
    }

    func testPayinMethodMatchOnlyInDefaultPayinMethod() throws {
        let defaultSwish = makeMethod(swish, isDefault: true)
        let statusData = makeStatusData(defaultPayinMethod: defaultSwish, payinMethods: [makeMethod(trustly)])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, defaultSwish)
        XCTAssertFalse(result.isProcessing)
    }

    func testPayinMethodPrefersActiveListedMethodOverPendingDefault() throws {
        let pendingDefaultSwish = makeMethod(swish, status: .pending, isDefault: true)
        let activeSwish = makeMethod(swish)
        let statusData = makeStatusData(defaultPayinMethod: pendingDefaultSwish, payinMethods: [activeSwish])

        let result = try XCTUnwrap(statusData.payinMethod(for: .swish))

        XCTAssertEqual(result.method, activeSwish)
        XCTAssertTrue(result.isProcessing)
    }
}
