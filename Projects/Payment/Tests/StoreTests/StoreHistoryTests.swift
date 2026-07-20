import AppStateContainer
import XCTest

@testable import Payment

@MainActor
final class StoreHistoryTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
    }

    override func tearDown() async throws {
        assert(store == nil)
    }

    func testGetHistorySuccess() async throws {
        let historyData: [PaymentHistoryListData] =
            [
                .init(
                    id: "id",
                    year: 2024,
                    valuesPerMonth: []
                )
            ]

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { historyData }
        )
        let store = PaymentStore()
        self.store = store
        await store.getHistory()
        assert(store.loadHistoryError == nil)
        assert(store.paymentHistory == historyData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentHistoryData)
    }

    func testGetHistoryFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.getHistory()
        assert(store.loadHistoryError != nil)
        assert(store.paymentHistory.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentHistoryData)
    }
}
