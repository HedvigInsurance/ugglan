import PresentableStore
import XCTest

@testable import Payment

final class StoreHistoryTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testGetHistorySuccess() async {
        let historyData: [PaymentHistoryListData] =
            [
                .init(
                    id: "id",
                    year: "2024",
                    valuesPerMonth: []
                )
            ]

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { historyData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getHistory)

        await waitUntil(description: "loading state") {
            store.loadingState[.getHistory] == nil
        }
        assert(store.state.paymentHistory == historyData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentHistoryData)
    }

    func testGetHistoryFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getHistory)
        await waitUntil(description: "loading state") {
            store.loadingState[.getHistory] != nil
        }
        assert(store.state.paymentHistory.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentHistoryData)
    }
}
