import Presentation
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

        assert(store.loadingSignal.value[.getHistory] == nil)
        assert(store.state.paymentHistory == historyData)
    }

    func testGetHistoryFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getHistory)

        assert(store.loadingSignal.value[.getHistory] != nil)
        assert(store.state.paymentHistory.isEmpty)
    }
}
