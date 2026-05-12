import PresentableStore
import XCTest

@testable import Payment

@MainActor
final class StoreMissedPaymentTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        XCTAssertNil(store)
    }

    func testGetMissedPaymentSuccess() async throws {
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
                provider: .trustly,
                status: .active,
                isDefault: true,
                details: .bankAccount(account: "descriptor", bank: "displayName")
            )
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchMissedPaymentData: { missedPaymentData }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getMissedPayment)
        try await Task.sleep(seconds: 0.3)
        XCTAssertNil(store.loadingState[.getMissedPayment])
        assert(store.state.missedPaymentData == missedPaymentData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }

    func testGetMissedPaymentSuccessNil() async throws {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchMissedPaymentData: { nil }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getMissedPayment)
        try await Task.sleep(seconds: 0.3)
        XCTAssertNil(store.loadingState[.getMissedPayment])
        assert(store.state.missedPaymentData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }

    func testGetMissedPaymentFailure() async throws {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchMissedPaymentData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.sendAsync(.getMissedPayment)
        try await Task.sleep(seconds: 0.3)
        assert(store.loadingState[.getMissedPayment] != nil)
        assert(store.state.missedPaymentData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }
}
