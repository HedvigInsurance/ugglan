import XCTest
import hCore

@testable import Payment

final class PaymentDetailsDiscountViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {
        try await Task.sleep(nanoseconds: 100)
    }

    func testPaymentDetailsDiscountViewModelRemoveTrueSuccess() async {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [
            .enableRemoving, .forPayment, .showExpire,
        ]

        let discount: Discount = .init(
            id: "id",
            code: "code",
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true
        )

        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == false)
        assert(model.shouldShowRemove == true)
    }

    func testPaymentDetailsDiscountViewModelRemoveFalseSuccess() async {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [.forPayment, .showExpire]

        let discount: Discount = .init(
            id: "id",
            code: "code",
            amount: .init(amount: "20", currency: "SEK"),
            title: "title",
            listOfAffectedInsurances: [],
            validUntil: nil,
            canBeDeleted: true
        )

        let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

        assert(model.shouldShowExpire == false)
        assert(model.shouldShowRemove == false)
    }

    func testPaymentDetailsDiscountViewModelExpireTrueSuccess() async {
        let options: PaymentDetailsDiscountViewModel.PaymentDetailsDiscountOptions = [.forPayment, .showExpire]

        if let date = "2024-07-07".localDateToDate {
            let nonValidServerBasedDate = date.localDateString

            let discount: Discount = .init(
                id: "id",
                code: "code",
                amount: .init(amount: "20", currency: "SEK"),
                title: "title",
                listOfAffectedInsurances: [],
                validUntil: nonValidServerBasedDate,
                canBeDeleted: true
            )

            let model = PaymentDetailsDiscountViewModel(options: options, discount: discount)

            assert(model.shouldShowExpire == true)
            assert(model.shouldShowRemove == false)
        }
    }
}
