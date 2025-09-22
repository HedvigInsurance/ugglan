@preconcurrency import XCTest
import hCore

@testable import Campaign

@MainActor
final class PaymentDetailsDiscountViewModelTests: XCTestCase {
    weak var sut: MockCampaignService?

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {
        try await super.tearDown()
        try await Task.sleep(nanoseconds: 100_000_000)
        Dependencies.shared.remove(for: hCampaignClient.self)
        XCTAssertNil(sut)
    }

    func testPaymentDetailsDiscountViewModelRemoveTrueSuccess() async throws {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [
            .forPayment, .showExpire,
        ]

        let discount: Discount = .init(
            code: "code",
            displayValue: MonetaryAmount.sek(20).formattedAmountPerMonth,
            description: "title",
            discountId: "code",
            type: .discount(status: .active)
        )

        let mockService = MockCampaignData.createMockCampaignService()
        sut = mockService

        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == false)
    }

    func testPaymentDetailsDiscountViewModelRemoveFalseSuccess() async throws {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [.forPayment, .showExpire]
        let discount: Discount = .init(
            code: "code",
            displayValue: MonetaryAmount.sek(20).formattedAmountPerMonth,
            description: "title",
            discountId: "code",
            type: .discount(status: .active)
        )

        let mockService = MockCampaignData.createMockCampaignService()
        sut = mockService

        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == false)
    }

    func testPaymentDetailsDiscountViewModelExpireTrueSuccess() async throws {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [.forPayment, .showExpire]

        let discount: Discount = .init(
            code: "code",
            displayValue: MonetaryAmount.sek(20).formattedAmountPerMonth,
            description: "title",
            discountId: "code",
            type: .discount(status: .terminated)
        )

        let mockService = MockCampaignData.createMockCampaignService()
        sut = mockService
        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == true)
    }
}
