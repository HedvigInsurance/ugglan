import Presentation
import XCTest

@testable import Payment

final class StorePaymentStatusTests: XCTestCase {
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

    func testFetchPaymentStatusSuccess() async {
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

        assert(store.loadingSignal.value[.getPaymentStatus] == nil)
        assert(store.state.paymentStatusData == statusData)
    }

    func testFetchPaymentStatusFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.fetchPaymentStatus)

        assert(store.loadingSignal.value[.getPaymentStatus] != nil)
        assert(store.state.paymentDiscountsData == nil)
    }
}
