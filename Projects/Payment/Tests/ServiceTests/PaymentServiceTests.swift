import XCTest
import hCore

@testable import Payment

final class PaymentServiceTests: XCTestCase {
    weak var sut: MockPaymentService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        try await Task.sleep(nanoseconds: 10000)

        XCTAssertNil(sut)
    }

    func testFetchPaymentDataSuccess() async {
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

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { paymentData }
        )
        self.sut = mockService

        let respondedPaymentData = try! await mockService.getPaymentData()
        assert(respondedPaymentData == paymentData)
    }

    func testFetchPaymentStatusDataSuccess() async {
        let paymentStatusData: PaymentStatusData = .init(
            status: .active,
            displayName: "displayName",
            descriptor: "descriptor"
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentStatusData: { paymentStatusData }
        )
        self.sut = mockService

        let respondedPaymentStatusData = try! await mockService.getPaymentStatusData()
        assert(respondedPaymentStatusData == paymentStatusData)
    }

    //    func testFetchPaymentDiscountsDataSuccess() async throws {
    //        let paymentDiscountsData: PaymentDiscountsData = .init(
    //            discounts: [],
    //            referralsData: .init(
    //                code: "code",
    //                discountPerMember: .init(amount: "10", currency: "SEK"),
    //                discount: .init(amount: "10", currency: "SEK"),
    //                referrals: []
    //            )
    //        )
    //
    //        let mockService = MockPaymentData.createMockPaymentService(
    //            fetchPaymentDiscountsData: { paymentDiscountsData }
    //        )
    //        self.sut = mockService
    //        try await Task.sleep(nanoseconds: 100_000_000)
    //        let respondedPaymentDiscountsData = try await mockService.getPaymentDiscountsData()
    //        assert(respondedPaymentDiscountsData == paymentDiscountsData)
    //    }

    func testFetchPaymentHistoryDataSuccess() async throws {
        let paymentHistoryData: [PaymentHistoryListData] = [
            .init(
                id: "id",
                year: "2023",
                valuesPerMonth: []
            )
        ]

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentHistoryData: { paymentHistoryData }
        )
        self.sut = mockService

        let respondedPaymentHistoryData = try await mockService.getPaymentHistoryData()
        assert(respondedPaymentHistoryData == paymentHistoryData)
    }

    func testFetchConnectPaymentUrlSuccess() async {
        let connectPaymentUrl = URL(string: "https://hedvig.se")

        let mockService = MockPaymentData.createMockPaymentService(
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
