import Presentation
import XCTest

@testable import Payment

final class StoreLoadTests: XCTestCase {
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

    func testLoadPaymentDataSuccess() async {
        let paymentData: PaymentData = .init(
            id: "id",
            payment: .init(
                gross: .init(amount: "230", currency: "SEK"),
                net: .init(amount: "230", currency: "SEK"),
                carriedAdjustment: .init(amount: "230", currency: "SEK"),
                settlementAdjustment: nil,
                date: .init()
            ),
            status: .success,
            contracts: [],
            discounts: [],
            paymentDetails: nil,
            addedToThePayment: nil
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { paymentData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.load)

        assert(store.loadingSignal.value[.getPaymentData] == nil)
        assert(store.state.paymentData == paymentData)
    }

    func testLoadPaymentFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.load)

        assert(store.loadingSignal.value[.getPaymentData] != nil)
        assert(store.state.paymentData == nil)
    }
}

extension XCTestCase {
    func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
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
