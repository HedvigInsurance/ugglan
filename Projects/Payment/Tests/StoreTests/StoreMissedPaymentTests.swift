import AppStateContainer
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class StoreMissedPaymentTests {
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
        func getMissedPaymentSuccess() async {
            do {
                let missedPaymentData = MissedPaymentData(
                    paymentData: .init(
                        id: "missed-id",
                        payment: .init(
                            gross: .init(amount: "230", currency: "SEK"),
                            net: .init(amount: "230", currency: "SEK"),
                            carriedAdjustment: .init(amount: "230", currency: "SEK"),
                            settlementAdjustment: nil,
                            date: .init()
                        ),
                        status: .upcoming,
                        contracts: [],
                        referralDiscount: nil,
                        amountPerReferral: .sek(20),
                        payinMethod: nil,
                        addedToThePayment: nil
                    ),
                    paymentMethodData: .init(
                        status: .active,
                        isDefault: true,
                        method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
                    )
                )

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { missedPaymentData }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getMissedPayment()
                #expect(store.loadMissedPaymentError == nil)
                #expect(store.missedPaymentData == missedPaymentData)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getMissedPaymentData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getMissedPaymentSuccessNil() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { nil }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getMissedPayment()
                #expect(store.loadMissedPaymentError == nil)
                #expect(store.missedPaymentData == nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getMissedPaymentData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getMissedPaymentFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getMissedPayment()
                #expect(store.loadMissedPaymentError != nil)
                #expect(store.missedPaymentData == nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getMissedPaymentData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getMissedPaymentRefetchesAfterFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store

                await store.getMissedPayment()
                #expect(store.loadMissedPaymentError != nil)

                mockService.fetchMissedPaymentData = { nil }
                await store.getMissedPayment()

                #expect(mockService.events.count == 2)
                #expect(store.loadMissedPaymentError == nil)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getMissedPaymentSkipsServiceWhileDataIsFresh() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { nil }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getMissedPayment()
                await store.getMissedPayment()
                #expect(mockService.events.count == 1)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func getMissedPaymentWithForceUpdateBypassesFreshness() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { nil }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.getMissedPayment()
                await store.getMissedPayment(forceUpdate: true)
                #expect(mockService.events.count == 2)
            }

            await expectStoreAndServiceReleased()
        }
    }
}
