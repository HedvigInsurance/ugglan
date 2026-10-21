import AppStateContainer
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class StorePaymentStatusTests {
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
        func fetchPaymentStatusSuccess() async {
            do {
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
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.fetchPaymentStatus()
                #expect(store.fetchPaymentStatusError == nil)
                #expect(store.paymentStatusData == statusData)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentStatusData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func fetchPaymentStatusFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentStatusData: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService
                let store = PaymentStore()
                self.store = store
                await store.fetchPaymentStatus()
                #expect(store.fetchPaymentStatusError != nil)
                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getPaymentStatusData)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func concurrentFetchPaymentStatusQueriesOnce() async {
            do {
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

                #expect(mockService.events == [.getPaymentStatusData])
                #expect(store.isFetchingPaymentStatus == false)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func fetchPaymentStatusFailureKeepsPreviousData() async {
            do {
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

                #expect(store.fetchPaymentStatusError != nil)
                #expect(store.paymentStatusData == statusData)
                #expect(mockService.events == [.getPaymentStatusData, .getPaymentStatusData])
            }

            await expectStoreAndServiceReleased()
        }
    }
}
