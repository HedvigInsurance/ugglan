import StoreContainer
import XCTest

@testable import Payment

final class StoreDiscountsTests: XCTestCase {
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

    func testFetchDiscountsSuccess() async {
        let discountsData: PaymentDiscountsData = .init(
            discounts: [
                .init(
                    id: "id",
                    code: "code",
                    amount: .init(amount: "30", currency: "SEK"),
                    title: "title",
                    listOfAffectedInsurances: [],
                    validUntil: nil,
                    canBeDeleted: true
                )
            ],
            referralsData: .init(
                code: "code1",
                discountPerMember: .init(amount: "10", currency: "SEK"),
                discount: .init(amount: "10", currency: "SEK"),
                referrals: [
                    .init(id: "referralId", name: "name", status: .active)
                ]
            )
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentDiscountsData: { discountsData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.fetchDiscountsData)
        await waitUntil(description: "loading state") {
            store.loadingState[.getDiscountsData] == nil
        }
        assert(store.state.paymentDiscountsData == discountsData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }

    func testFetchDiscountsFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentDiscountsData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.fetchDiscountsData)

        await waitUntil(description: "loading state") {
            store.loadingState[.getDiscountsData] != nil
        }
        assert(store.state.paymentDiscountsData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }
}
