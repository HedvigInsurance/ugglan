import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class StoreLoadTests {
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
        func loadPaymentDataSuccess() async {
            do {
                let paymentData: (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData]) = (
                    upcoming: .init(
                        id: "id1",
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
                    ongoing: [
                        .init(
                            id: "id2",
                            payment: .init(
                                gross: .init(amount: "230", currency: "SEK"),
                                net: .init(amount: "230", currency: "SEK"),
                                carriedAdjustment: .init(amount: "230", currency: "SEK"),
                                settlementAdjustment: nil,
                                date: .init()
                            ),
                            status: .pending,
                            contracts: [],
                            referralDiscount: nil,
                            amountPerReferral: .sek(15),
                            payinMethod: nil,
                            addedToThePayment: nil
                        )
                    ]
                )

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { paymentData }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.load()
                #expect(store.ongoingPaymentData == paymentData.ongoing)
                #expect(store.paymentData == paymentData.upcoming)
                #expect(store.loadPaymentDataError == nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentData)
                #expect(store.paymentDataFetchedAt != nil)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func loadSkipsServiceWhileDataIsFresh() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { (upcoming: nil, ongoing: []) }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.load()
                await store.load()
                #expect(mockService.events.count == 1)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func loadWithForceUpdateBypassesFreshness() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { (upcoming: nil, ongoing: []) }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.load()
                await store.load(forceUpdate: true)
                #expect(mockService.events.count == 2)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func loadRefetchesWhenDataIsStale() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { (upcoming: nil, ongoing: []) }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                store.paymentDataFetchedAt = Date(timeIntervalSinceNow: -31 * 60)
                await store.load()
                #expect(mockService.events.count == 1)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func loadPaymentFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.load()
                #expect(store.loadPaymentDataError != nil)
                #expect(store.paymentData == nil)
                #expect(store.ongoingPaymentData.isEmpty)
                #expect(store.paymentDataFetchedAt == nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentData)
            }

            await expectStoreAndServiceReleased()
        }
    }
}
