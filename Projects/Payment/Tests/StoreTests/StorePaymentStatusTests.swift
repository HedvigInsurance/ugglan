import PresentableStore
@preconcurrency import XCTest

@testable import Payment

@MainActor
final class StorePaymentStatusTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(store)
    }

    func testFetchPaymentStatusSuccess() async throws {
        let statusData: PaymentStatusData = .init(
            status: .active,
            displayName: "display name",
            descriptor: "descriptor"
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { statusData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.fetchPaymentStatus)
        try await Task.sleep(seconds: 0.1)
        XCTAssertNil(store.loadingState[.getPaymentStatus])
        assert(store.state.paymentStatusData == statusData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentStatusData)
    }

    func testFetchPaymentStatusFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.fetchPaymentStatus)
        assert(store.loadingState[.getPaymentStatus] != nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentStatusData)
    }
}
