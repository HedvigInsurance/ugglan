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
                    payinMethod: nil,
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
                        payinMethod: nil,
                        addedToThePayment: nil
                    )
                ]
            )
        },
        fetchPaymentStatusData: @escaping FetchPaymentStatusData = {
            .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: nil,
                payinMethods: [],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: []
            )
        },
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData = {
            .init()
        },
        fetchSetupPaymentMethod: @escaping FetchSetupPaymentMethod = {
            .init(status: .pending, url: "https://example.com/setup", errorMessage: nil)
        }
    ) -> MockPaymentService {
        let service = MockPaymentService(
            fetchPaymentData: fetchPaymentData,
            fetchPaymentStatusData: fetchPaymentStatusData,
            fetchPaymentHistoryData: fetchPaymentHistoryData,
            fetchSetupPaymentMethod: fetchSetupPaymentMethod
        )
        Dependencies.shared.add(module: Module { () -> hPaymentClient in service })
        return service
    }
}

typealias FetchPaymentData = () async throws -> (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData])
typealias FetchPaymentStatusData = () async throws -> PaymentStatusData
typealias FetchPaymentHistoryData = () async throws -> [PaymentHistoryListData]
typealias FetchSetupPaymentMethod = () async throws -> PaymentSetupResult

class MockPaymentService: hPaymentClient {
    var events = [Event]()

    var fetchPaymentData: FetchPaymentData
    var fetchPaymentStatusData: FetchPaymentStatusData
    var fetchPaymentHistoryData: FetchPaymentHistoryData
    var fetchSetupPaymentMethod: FetchSetupPaymentMethod

    enum Event {
        case getPaymentData
        case getPaymentStatusData
        case getPaymentHistoryData
        case setupPaymentMethod
    }

    init(
        fetchPaymentData: @escaping FetchPaymentData,
        fetchPaymentStatusData: @escaping FetchPaymentStatusData,
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData,
        fetchSetupPaymentMethod: @escaping FetchSetupPaymentMethod
    ) {
        self.fetchPaymentData = fetchPaymentData
        self.fetchPaymentStatusData = fetchPaymentStatusData
        self.fetchPaymentHistoryData = fetchPaymentHistoryData
        self.fetchSetupPaymentMethod = fetchSetupPaymentMethod
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

    func setupPaymentMethod(_ type: PaymentMethodSetupType) async throws -> PaymentSetupResult {
        events.append(.setupPaymentMethod)
        let data = try await fetchSetupPaymentMethod()
        return data
    }
}
