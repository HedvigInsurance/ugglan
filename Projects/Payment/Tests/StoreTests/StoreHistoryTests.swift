import AppStateContainer
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class StoreHistoryTests {
        private weak var store: PaymentStore?
        private weak var sut: MockPaymentService?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectStoreAndServiceReleased() async {
            Dependencies.shared.remove(for: hPaymentClient.self)
            await delay(0.00001)

            #expect(store == nil, "the payment store must not outlive the test that created it")
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func getHistorySuccess() async {
            do {
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
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getHistory()
                #expect(store.loadHistoryError == nil)
                #expect(store.paymentHistory == historyData)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentHistoryData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getHistoryFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentHistoryData: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getHistory()
                #expect(store.loadHistoryError != nil)
                #expect(store.paymentHistory.isEmpty)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentHistoryData)
            }

            await expectStoreAndServiceReleased()
        }
    }
}
