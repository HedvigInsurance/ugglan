import Testing
import hCore
import hCoreUI

@testable import Campaign

@MainActor
@Suite(.serialized)
final class PaymentsDiscountsViewModelTests {
    weak var sut: PaymentsDiscountsViewModel?

    deinit {
        MainActor.assumeIsolated {
            Dependencies.shared.remove(for: hCampaignClient.self)
            assert(sut == nil)
        }
    }

    @Test func fetchDiscountsSuccess() async throws {
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
        #expect(vm.viewState == .success)
        #expect(vm.paymentDiscountsData == discountsData)
        #expect(mockService.events.count == 1)
        #expect(mockService.events.first == .getPaymentDiscountsData)
    }

    @Test func fetchDiscountsFailure() async throws {
        let mockService = MockCampaignData.createMockCampaignService(
            fetchPaymentDiscountsData: { throw MockCampaignError.failure }
        )
        let vm = PaymentsDiscountsViewModel()
        sut = vm
        await vm.fetchDiscountsData()
        #expect(vm.viewState == .error(errorMessage: L10n.General.errorBody))
        #expect(vm.paymentDiscountsData == nil)
        #expect(mockService.events.count == 1)
        #expect(mockService.events.first == .getPaymentDiscountsData)
    }
}
