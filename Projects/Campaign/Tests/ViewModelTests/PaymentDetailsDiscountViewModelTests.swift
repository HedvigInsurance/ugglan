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
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true,
            discountId: "id"
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
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true,
            discountId: "id"
        )

        let mockService = MockCampaignData.createMockCampaignService()
        sut = mockService

        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == false)
    }

    func testPaymentDetailsDiscountViewModelExpireTrueSuccess() async throws {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [.forPayment, .showExpire]
        if let date = "2024-07-07".localDateToDate {
            let nonValidServerBasedDate = date.localDateString

            let discount: Discount = .init(
                code: "code",
                amount: .init(amount: "20", currency: "SEK"),
                title: "title",
                listOfAffectedInsurances: [],
                validUntil: nonValidServerBasedDate,
                canBeDeleted: true,
                discountId: "id"
            )

            let mockService = MockCampaignData.createMockCampaignService()
            sut = mockService
            let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

            assert(model.shouldShowExpire == true)
        }
    }
}
