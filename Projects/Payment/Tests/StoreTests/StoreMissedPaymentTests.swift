import AppStateContainer
import XCTest

@testable import Payment

@MainActor
final class StoreMissedPaymentTests: XCTestCase {
    weak var store: PaymentStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
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
        await store.getMissedPayment()
        XCTAssertNil(store.loadMissedPaymentError)
        assert(store.missedPaymentData == missedPaymentData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }

    func testGetMissedPaymentSuccessNil() async throws {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchMissedPaymentData: { nil }
        )
        let store = PaymentStore()
        self.store = store
        await store.getMissedPayment()
        XCTAssertNil(store.loadMissedPaymentError)
        assert(store.missedPaymentData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }

    func testGetMissedPaymentFailure() async throws {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchMissedPaymentData: { throw PaymentError.missingDataError(message: "error") }
        )
        let store = PaymentStore()
        self.store = store
        await store.getMissedPayment()
        assert(store.loadMissedPaymentError != nil)
        assert(store.missedPaymentData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMissedPaymentData)
    }
}
