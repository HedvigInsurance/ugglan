import Foundation

@testable import Payment

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
