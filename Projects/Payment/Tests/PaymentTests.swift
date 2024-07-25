import XCTest
import hCore

@testable import Payment

final class PaymentTests: XCTestCase {
    weak var sut: MockPaymentService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func fetchPaymentDataSuccess() async {
        let paymentData: PaymentData = .init(
            id: "id",
            payment: .init(
                gross: .init(amount: "230", currency: "SEK"),
                net: .init(amount: "230", currency: "SEK"),
                carriedAdjustment: .init(amount: "230", currency: "SEK"),
                settlementAdjustment: nil,
                date: .init()
            ),
            status: .success,
            contracts: [],
            discounts: [],
            paymentDetails: nil,
            addedToThePayment: nil
        )

        let mockService = MockData.createMockTravelInsuranceService(
            fetchPaymentData: { paymentData }
        )
        self.sut = mockService

        let respondedPaymentData = try! await mockService.getPaymentData()
        assert(respondedPaymentData == paymentData)
    }
}
