import Foundation
import hCore

@testable import Payment

@MainActor

struct MockPaymentData {
    @discardableResult static func createMockPaymentService(
        fetchPaymentData: @escaping FetchPaymentData = {
            (
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
                    paymentChargeData: nil,
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
                        amountPerReferral: .sek(25),
                        paymentChargeData: nil,
                        addedToThePayment: nil
                    )
                ]
            )
        },
        fetchPaymentStatusData: @escaping FetchPaymentStatusData = {
            .init(status: .active, paymentChargeData: nil)
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
            fetchPaymentHistoryData: fetchPaymentHistoryData,
            fetchConnectPaymentUrl: fetchConnectPaymentUrl
        )
        Dependencies.shared.add(module: Module { () -> hPaymentClient in service })
        return service
    }
}

typealias FetchPaymentData = () async throws -> (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData])
typealias FetchPaymentStatusData = () async throws -> PaymentStatusData
typealias FetchPaymentHistoryData = () async throws -> [PaymentHistoryListData]
typealias FetchConnectPaymentUrl = () async throws -> URL

class MockPaymentService: hPaymentClient {
    var events = [Event]()

    var fetchPaymentData: FetchPaymentData
    var fetchPaymentStatusData: FetchPaymentStatusData
    var fetchPaymentHistoryData: FetchPaymentHistoryData
    var fetchConnectPaymentUrl: FetchConnectPaymentUrl

    enum Event {
        case getPaymentData
        case getPaymentStatusData
        case getPaymentHistoryData
        case getConnectPaymentUrl
    }

    init(
        fetchPaymentData: @escaping FetchPaymentData,
        fetchPaymentStatusData: @escaping FetchPaymentStatusData,
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData,
        fetchConnectPaymentUrl: @escaping FetchConnectPaymentUrl
    ) {
        self.fetchPaymentData = fetchPaymentData
        self.fetchPaymentStatusData = fetchPaymentStatusData
        self.fetchPaymentHistoryData = fetchPaymentHistoryData
        self.fetchConnectPaymentUrl = fetchConnectPaymentUrl
    }

    func getPaymentData() async throws -> (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData]) {
        events.append(.getPaymentData)
        let data = try await fetchPaymentData()
        return data
    }

    func getPaymentStatusData() async throws -> PaymentStatusData {
        events.append(.getPaymentStatusData)
        let data = try await fetchPaymentStatusData()
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
