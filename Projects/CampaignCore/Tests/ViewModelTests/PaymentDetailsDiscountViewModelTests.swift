import Testing
import hCore

@testable import CampaignCore

@MainActor
final class PaymentDetailsDiscountViewModelTests {
    @Test
    func fetchDiscountsSuccess() async throws {
        let discountsData: PaymentDiscountsData = .init(
            discountsData: [
                DiscountsDataForInsurance(
                    id: "contractId",
                    displayName: "displayName",
                    info: nil,
                    discounts: [
                        .init(
                            code: "code",
                            displayValue: MonetaryAmount.sek(30).formattedAmountPerMonth,
                            description: "title",
                            type: .discount(status: .terminated)
                        )
                    ]
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
        let vm = PaymentsDiscountsRootViewModel()
        await vm.fetch()
        #expect(vm.viewState == .success)
        #expect(vm.paymentDiscountsData == discountsData)
        #expect(mockService.events.count == 1)
        #expect(mockService.events.first == .getPaymentDiscountsData)
    }

    @Test
    func fetchDiscountsFailure() async throws {
        let mockService = MockCampaignData.createMockCampaignService(
            fetchPaymentDiscountsData: { throw MockCampaignError.failure }
        )
        let vm = PaymentsDiscountsRootViewModel()
        await vm.fetch()
        #expect(vm.viewState == .error(errorMessage: L10n.General.errorBody))
        #expect(vm.paymentDiscountsData == nil)
        #expect(mockService.events.count == 1)
        #expect(mockService.events.first == .getPaymentDiscountsData)
    }
}
