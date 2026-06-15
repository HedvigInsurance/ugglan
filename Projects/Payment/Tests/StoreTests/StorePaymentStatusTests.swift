import AppStateContainer
import XCTest

@testable import Payment

@MainActor
final class StorePaymentStatusTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(store)
    }

    func testFetchPaymentStatusSuccess() async throws {
        let statusData: PaymentStatusData = .init(
            status: .active,
            chargingDay: 27,
            defaultPayinMethod: .init(
                provider: .trustly,
                status: .active,
                isDefault: true,
                details: .bankAccount(account: "descriptor", bank: "displayName")
            ),
            payinMethods: [
                .init(
                    provider: .trustly,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "descriptor", bank: "displayName")
                )
            ],
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: nil,
            layout: .other
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { statusData }
        )
        let store = PaymentStore()
        self.store = store
        await store.fetchPaymentStatus()
        XCTAssertNil(store.fetchPaymentStatusError)
        assert(store.paymentStatusData == statusData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentStatusData)
    }

    func testFetchPaymentStatusFailure() async throws {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.fetchPaymentStatus()
        assert(store.fetchPaymentStatusError != nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentStatusData)
    }
}
