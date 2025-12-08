import PresentableStore
@preconcurrency import XCTest

@testable import Payment

@MainActor
final class StoreLoadTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(store)
    }

    func testLoadPaymentDataSuccess() async throws {
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
                paymentChargeData: nil,
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
                    paymentChargeData: nil,
                    addedToThePayment: nil
                )
            ]
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { paymentData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.load)
        try await Task.sleep(seconds: 0.1)
        XCTAssertNil(store.loadingState[.getPaymentData])
        assert(store.state.ongoingPaymentData == paymentData.ongoing)
        assert(store.state.paymentData == paymentData.upcoming)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentData)
    }

    func testLoadPaymentFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.load)
        XCTAssertNotNil(store.loadingState[.getPaymentData])
        assert(store.state.paymentData == nil)
        assert(store.state.ongoingPaymentData.isEmpty)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentData)
    }
}

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(seconds: 0.1)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
