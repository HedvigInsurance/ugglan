import PresentableStore
@preconcurrency import XCTest
import hCore

@testable import Campaign

@MainActor
final class StoreDiscountsTests: XCTestCase {
    weak var store: CampaignStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: hCampaignClient.self)
        assert(store == nil)
    }

    func testFetchDiscountsSuccess() async throws {
        let discounts: [Discount] = [
            .init(
                code: "code",
                displayValue: MonetaryAmount.sek(30).formattedAmountPerMonth,
                description: "title",
                type: .discount(status: .terminated)
            )
        ]

        let discountsData: PaymentDiscountsData = .init(
            discountsData: [
                DiscountsDataForInsurance.init(
                    id: "contractId",
                    displayName: "displayName",
                    info: nil,
                    discounts: discounts
                )
            ],
            referralsData: .init(
                discountPerMember: .init(amount: "10", currency: "SEK"),
                referrals: [
                    .init(id: "referralId", name: "name", code: nil, description: "desciption")
                ]
            )
        )

        let mockService = MockCampaignData.createMockCampaignService(
            fetchPaymentDiscountsData: { discountsData }
        )
        let store = CampaignStore()
        self.store = store
        await store.sendAsync(.fetchDiscountsData)
        try await Task.sleep(seconds: 0.1)
        assert(store.loadingState[.getDiscountsData] == nil)
        assert(store.state.paymentDiscountsData == discountsData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }

    func testFetchDiscountsFailure() async throws {
        let mockService = MockCampaignData.createMockCampaignService(
            fetchPaymentDiscountsData: { throw MockCampaignError.failure }
        )
        let store = CampaignStore()
        self.store = store
        await store.sendAsync(.fetchDiscountsData)
        try await Task.sleep(seconds: 0.1)
        assert(store.loadingState[.getDiscountsData] != nil)
        assert(store.state.paymentDiscountsData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }
}
