import AppStateContainer
import XCTest
import hCore

@testable import Payment

@MainActor
final class StorePaymentStatusTests: XCTestCase {
    weak var store: PaymentStore?
    weak var sut: MockPaymentService?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(store)
        XCTAssertNil(sut)
    }

    func testFetchPaymentStatusSuccess() async throws {
        let statusData: PaymentStatusData = .init(
            status: .active,
            chargingDay: 27,
            defaultPayinMethod: .init(
                status: .active,
                isDefault: true,
                method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
            ),
            payinMethods: [
                .init(
                    status: .active,
                    isDefault: true,
                    method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
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

    func testConcurrentFetchPaymentStatusQueriesOnce() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: {
                await delay(0.05)
                return .init(
                    status: .active,
                    chargingDay: nil,
                    defaultPayinMethod: nil,
                    payinMethods: [],
                    defaultPayoutMethod: nil,
                    payoutMethods: [],
                    availableMethods: [],
                    missingConnection: nil,
                    layout: .other
                )
            }
        )
        sut = mockService
        let store = PaymentStore()
        self.store = store

        async let first: () = store.fetchPaymentStatus()
        async let second: () = store.fetchPaymentStatus()
        _ = await (first, second)

        XCTAssertEqual(mockService.events, [.getPaymentStatusData])
        XCTAssertFalse(store.isFetchingPaymentStatus)
    }

    func testFetchPaymentStatusFailureKeepsPreviousData() async throws {
        let statusData: PaymentStatusData = .init(
            status: .needsSetup,
            chargingDay: 27,
            defaultPayinMethod: nil,
            payinMethods: [],
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: .payin,
            layout: .other
        )
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { statusData }
        )
        sut = mockService
        let store = PaymentStore()
        self.store = store
        await store.fetchPaymentStatus()

        mockService.fetchPaymentStatusData = { throw PaymentError.missingDataError(message: "error") }
        await store.fetchPaymentStatus()

        XCTAssertNotNil(store.fetchPaymentStatusError)
        XCTAssertEqual(store.paymentStatusData, statusData)
        XCTAssertEqual(mockService.events, [.getPaymentStatusData, .getPaymentStatusData])
    }
}
