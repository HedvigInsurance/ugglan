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

        let mockService = MockData.createMockPaymentService(
            fetchPaymentData: { paymentData }
        )
        self.sut = mockService

        let respondedPaymentData = try! await mockService.getPaymentData()
        assert(respondedPaymentData == paymentData)
    }

    func fetchPaymentStatusDataSuccess() async {
        let paymentStatusData: PaymentStatusData = .init(
            status: .active,
            displayName: "displayName",
            descriptor: "descriptor"
        )

        let mockService = MockData.createMockPaymentService(
            fetchPaymentStatusData: { paymentStatusData }
        )
        self.sut = mockService

        let respondedPaymentStatusData = try! await mockService.getPaymentStatusData()
        assert(respondedPaymentStatusData == paymentStatusData)
    }

    func fetchPaymentDiscountsDataSuccess() async {
        let paymentDiscountsData: PaymentDiscountsData = .init(
            discounts: [],
            referralsData: .init(
                code: "code",
                discountPerMember: .init(amount: "10", currency: "SEK"),
                discount: .init(amount: "10", currency: "SEK"),
                referrals: []
            )
        )

        let mockService = MockData.createMockPaymentService(
            fetchPaymentDiscountsData: { paymentDiscountsData }
        )
        self.sut = mockService

        let respondedPaymentDiscountsData = try! await mockService.getPaymentDiscountsData()
        assert(respondedPaymentDiscountsData == paymentDiscountsData)
    }

    func fetchPaymentHistoryDataSuccess() async {
        let paymentHistoryData: [PaymentHistoryListData] = [
            .init(
                id: "id",
                year: "2023",
                valuesPerMonth: []
            )
        ]

        let mockService = MockData.createMockPaymentService(
            fetchPaymentHistoryData: { paymentHistoryData }
        )
        self.sut = mockService

        let respondedPaymentHistoryData = try! await mockService.getPaymentHistoryData()
        assert(respondedPaymentHistoryData == paymentHistoryData)
    }

    func fetchConnectPaymentUrlSuccess() async {
        let connectPaymentUrl = URL(string: "https://hedvig.se")

        let mockService = MockData.createMockPaymentService(
            fetchConnectPaymentUrl: {
                if let connectPaymentUrl {
                    return connectPaymentUrl
                }
                throw PaymentError.missingDataError(message: L10n.General.errorBody)
            }
        )
        self.sut = mockService

        let respondedConnectPaymentUrl = try! await mockService.getConnectPaymentUrl()
        assert(respondedConnectPaymentUrl == connectPaymentUrl)
    }
}
