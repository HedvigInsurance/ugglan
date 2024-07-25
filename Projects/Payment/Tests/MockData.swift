import Foundation
import hCore

@testable import Payment

struct MockData {
    static func createMockTravelInsuranceService(
        fetchPaymentData: @escaping FetchPaymentData = {
            .init(
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
        },
        fetchPaymentStatusData: @escaping FetchPaymentStatusData = {
            .init(status: .active, displayName: nil, descriptor: nil)
        },
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData = {
            .init(
                discounts: [],
                referralsData: .init(
                    code: "code",
                    discountPerMember: .init(amount: "10", currency: "SEK"),
                    discount: .init(amount: "10", currency: "SEK"),
                    referrals: []
                )
            )
        },
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData = {
            .init()
        },
        fetchConnectPaymentUrl: @escaping FetchConnectPaymentUrl = {
            if let url = URL(string: "") {
                return url
            }
            throw PaymentError.missingDataError(message: L10n.General.errorBody)
        }
    ) -> MockPaymentService {
        let service = MockPaymentService(
            fetchPaymentData: fetchPaymentData,
            fetchPaymentStatusData: fetchPaymentStatusData,
            fetchPaymentDiscountsData: fetchPaymentDiscountsData,
            fetchPaymentHistoryData: fetchPaymentHistoryData,
            fetchConnectPaymentUrl: fetchConnectPaymentUrl
        )
        Dependencies.shared.add(module: Module { () -> hPaymentClient in service })
        return service
    }
}

typealias FetchPaymentData = () async throws -> PaymentData?
typealias FetchPaymentStatusData = () async throws -> PaymentStatusData
typealias FetchPaymentDiscountsData = () async throws -> PaymentDiscountsData
typealias FetchPaymentHistoryData = () async throws -> [PaymentHistoryListData]
typealias FetchConnectPaymentUrl = () async throws -> URL

class MockPaymentService: hPaymentClient {
    var events = [Event]()

    var fetchPaymentData: FetchPaymentData
    var fetchPaymentStatusData: FetchPaymentStatusData
    var fetchPaymentDiscountsData: FetchPaymentDiscountsData
    var fetchPaymentHistoryData: FetchPaymentHistoryData
    var fetchConnectPaymentUrl: FetchConnectPaymentUrl

    enum Event {
        case getPaymentData
        case getPaymentStatusData
        case getPaymentDiscountsData
        case getPaymentHistoryData
        case getConnectPaymentUrl
    }

    init(
        fetchPaymentData: @escaping FetchPaymentData,
        fetchPaymentStatusData: @escaping FetchPaymentStatusData,
        fetchPaymentDiscountsData: @escaping FetchPaymentDiscountsData,
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData,
        fetchConnectPaymentUrl: @escaping FetchConnectPaymentUrl
    ) {
        self.fetchPaymentData = fetchPaymentData
        self.fetchPaymentStatusData = fetchPaymentStatusData
        self.fetchPaymentDiscountsData = fetchPaymentDiscountsData
        self.fetchPaymentHistoryData = fetchPaymentHistoryData
        self.fetchConnectPaymentUrl = fetchConnectPaymentUrl
    }

    func getPaymentData() async throws -> PaymentData? {
        events.append(.getPaymentData)
        let data = try await fetchPaymentData()
        return data
    }

    func getPaymentStatusData() async throws -> PaymentStatusData {
        events.append(.getPaymentStatusData)
        let data = try await fetchPaymentStatusData()
        return data
    }

    func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        events.append(.getPaymentDiscountsData)
        let data = try await fetchPaymentDiscountsData()
        return data
    }

    func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        events.append(.getPaymentHistoryData)
        let data = try await fetchPaymentHistoryData()
        return data
    }

    func getConnectPaymentUrl() async throws -> URL {
        events.append(.getConnectPaymentUrl)
        let data = try await fetchConnectPaymentUrl()
        return data
    }
}
