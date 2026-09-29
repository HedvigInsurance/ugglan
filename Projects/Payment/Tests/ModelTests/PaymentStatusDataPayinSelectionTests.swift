@preconcurrency import XCTest

@testable import Payment

@MainActor
final class PaymentStatusDataPayinSelectionTests: XCTestCase {
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

    private func makeStatusData(payinMethods: [ConnectedPaymentMethod]) -> PaymentStatusData {
        .init(
            status: .active,
            chargingDay: 27,
            defaultPayinMethod: payinMethods.first(where: \.isDefault),
            payinMethods: payinMethods,
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: nil,
            layout: .other
        )
    }

    // MARK: - activePayinMethods

    func testActivePayinMethodsEmptyWithoutMethods() {
        let statusData = makeStatusData(payinMethods: [])

        XCTAssertEqual(statusData.activePayinMethods, [])
    }

    func testActivePayinMethodsIncludesOnlyActiveMethods() {
        let activeTrustly = makeMethod(trustly, isDefault: true)
        let pendingSwish = makeMethod(swish, status: .pending)
        let unknownInvoice = makeMethod(invoice, status: .unknown)
        let activeSwish = makeMethod(swish)
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, unknownInvoice, activeSwish])

        XCTAssertEqual(statusData.activePayinMethods, [activeTrustly, activeSwish])
    }

    // MARK: - selectablePayinMethods

    func testSelectablePayinMethodsDefaultFirst() {
        let activeTrustly = makeMethod(trustly)
        let defaultInvoice = makeMethod(invoice, isDefault: true)
        let activeSwish = makeMethod(swish)
        let statusData = makeStatusData(payinMethods: [activeTrustly, defaultInvoice, activeSwish])

        XCTAssertEqual(statusData.selectablePayinMethods, [defaultInvoice, activeTrustly, activeSwish])
    }

    func testSelectablePayinMethodsPreservesBackendOrderWithoutDefault() {
        let activeSwish = makeMethod(swish)
        let activeInvoice = makeMethod(invoice)
        let activeTrustly = makeMethod(trustly)
        let statusData = makeStatusData(payinMethods: [activeSwish, activeInvoice, activeTrustly])

        XCTAssertEqual(statusData.selectablePayinMethods, [activeSwish, activeInvoice, activeTrustly])
    }

    func testSelectablePayinMethodsExcludesPendingMethods() {
        let activeTrustly = makeMethod(trustly)
        let pendingSwish = makeMethod(swish, status: .pending)
        let defaultInvoice = makeMethod(invoice, isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, defaultInvoice])

        XCTAssertEqual(statusData.selectablePayinMethods, [defaultInvoice, activeTrustly])
    }

    func testSelectablePayinMethodsExcludesPendingDefault() {
        let pendingDefaultSwish = makeMethod(swish, status: .pending, isDefault: true)
        let activeTrustly = makeMethod(trustly)
        let statusData = makeStatusData(payinMethods: [pendingDefaultSwish, activeTrustly])

        XCTAssertEqual(statusData.selectablePayinMethods, [activeTrustly])
    }

    func testSelectablePayinMethodsEmptyWhenAllPending() {
        let statusData = makeStatusData(
            payinMethods: [makeMethod(swish, status: .pending), makeMethod(trustly, status: .pending)]
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
            payinMethods: [makeMethod(swish, status: .pending), makeMethod(trustly, status: .pending)]
        )

        XCTAssertFalse(statusData.canChooseDefaultPayinMethod)
    }

    func testCanChooseDefaultPayinMethodWithOneActiveMethod() {
        let statusData = makeStatusData(
            payinMethods: [makeMethod(trustly, isDefault: true), makeMethod(swish, status: .pending)]
        )

        XCTAssertFalse(statusData.canChooseDefaultPayinMethod)
    }

    func testCanChooseDefaultPayinMethodWithTwoActiveMethods() {
        let statusData = makeStatusData(
            payinMethods: [makeMethod(trustly, isDefault: true), makeMethod(swish)]
        )

        XCTAssertTrue(statusData.canChooseDefaultPayinMethod)
    }
}
