@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class PaymentServiceTests: XCTestCase {
    weak var sut: MockPaymentService?

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        try await Task.sleep(seconds: 0.00001)

        XCTAssertNil(sut)
    }

    func testFetchPaymentDataSuccess() async {
        let paymentData: (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData]) = (
            upcoming: .init(
                id: "id1",
                payment: .init(
                    gross: .init(amount: "230", currency: "SEK"),
                    net: .init(amount: "230", currency: "SEK"),
                    carriedAdjustment: .init(amount: "230", currency: "SEK"),
                    settlementAdjustment: nil,
                    date: .init()
                ),
                status: .upcoming,
                contracts: [],
                referralDiscount: nil,
                amountPerReferral: .sek(20),
                paymentDetails: nil,
                addedToThePayment: nil
            ),
            ongoing: [
                .init(
                    id: "id2",
                    payment: .init(
                        gross: .init(amount: "230", currency: "SEK"),
                        net: .init(amount: "230", currency: "SEK"),
                        carriedAdjustment: .init(amount: "230", currency: "SEK"),
                        settlementAdjustment: nil,
                        date: .init()
                    ),
                    status: .pending,
                    contracts: [],
                    referralDiscount: nil,
                    amountPerReferral: .sek(10),
                    paymentDetails: nil,
                    addedToThePayment: nil
                )
            ]
        )

        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentData: { paymentData }
        )
        sut = mockService

        let respondedPaymentData = try! await mockService.getPaymentData()
        assert(respondedPaymentData.ongoing == paymentData.ongoing)
        assert(respondedPaymentData.upcoming == paymentData.upcoming)
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
        sut = mockService

        let respondedPaymentStatusData = try! await mockService.getPaymentStatusData()
        assert(respondedPaymentStatusData == paymentStatusData)
    }

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
        sut = mockService

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
        sut = mockService

        let respondedConnectPaymentUrl = try! await mockService.getConnectPaymentUrl()
        assert(respondedConnectPaymentUrl == connectPaymentUrl)
    }
}
