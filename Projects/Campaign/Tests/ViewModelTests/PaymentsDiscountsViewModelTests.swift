import XCTest
import hCore
import hCoreUI

@testable import Campaign

@MainActor
final class PaymentsDiscountsViewModelTests: XCTestCase {
    weak var sut: PaymentsDiscountsViewModel?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: hCampaignClient.self)
        assert(sut == nil)
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
        let vm = PaymentsDiscountsViewModel()
        sut = vm
        await vm.fetchDiscountsData()
        assert(vm.viewState == .success)
        assert(vm.paymentDiscountsData == discountsData)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }

    func testFetchDiscountsFailure() async throws {
        let mockService = MockCampaignData.createMockCampaignService(
            fetchPaymentDiscountsData: { throw MockCampaignError.failure }
        )
        let vm = PaymentsDiscountsViewModel()
        sut = vm
        await vm.fetchDiscountsData()
        assert(vm.viewState == .error(errorMessage: L10n.General.errorBody))
        assert(vm.paymentDiscountsData == nil)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getPaymentDiscountsData)
    }
}
