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
                availableMethods: [],
                missingConnection: nil,
                layout: .other
            )
        },
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData = {
            .init()
        },
        fetchSetupPaymentMethod: @escaping FetchSetupPaymentMethod = {
            .init(status: .pending, orderId: "order-1", url: "https://example.com/setup", errorMessage: nil)
        },
        fetchPaymentSetupStatus: @escaping FetchPaymentSetupStatus = { .active },
        fetchMissedPaymentData: @escaping FetchMissedPaymentData = { nil },
        chargeOutstandingPayment: @escaping ChargeOutstandingPayment = {},
        setDefaultPaymentMethod: @escaping SetDefaultPaymentMethod = {},
        removePaymentMethod: @escaping RemovePaymentMethod = {}
    ) -> MockPaymentService {
        let service = MockPaymentService(
            fetchPaymentData: fetchPaymentData,
            fetchPaymentStatusData: fetchPaymentStatusData,
            fetchPaymentHistoryData: fetchPaymentHistoryData,
            fetchSetupPaymentMethod: fetchSetupPaymentMethod,
            fetchPaymentSetupStatus: fetchPaymentSetupStatus,
            fetchMissedPaymentData: fetchMissedPaymentData,
            chargeOutstandingPayment: chargeOutstandingPayment,
            setDefaultPaymentMethod: setDefaultPaymentMethod,
            removePaymentMethod: removePaymentMethod
        )
        Dependencies.shared.add(module: Module { () -> hPaymentClient in service })
        return service
    }
}

typealias FetchPaymentData = () async throws -> (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData])
typealias FetchPaymentStatusData = () async throws -> PaymentStatusData
typealias FetchPaymentHistoryData = () async throws -> [PaymentHistoryListData]
typealias FetchSetupPaymentMethod = () async throws -> PaymentSetupResult
typealias FetchPaymentSetupStatus = () async throws -> PaymentSetupResult.PaymentSetupStatus
typealias FetchMissedPaymentData = () async throws -> MissedPaymentData?
typealias ChargeOutstandingPayment = () async throws -> Void
typealias SetDefaultPaymentMethod = () async throws -> Void
typealias RemovePaymentMethod = () async throws -> Void

class MockPaymentService: hPaymentClient {
    var events = [Event]()

    var fetchPaymentData: FetchPaymentData
    var fetchPaymentStatusData: FetchPaymentStatusData
    var fetchPaymentHistoryData: FetchPaymentHistoryData
    var fetchSetupPaymentMethod: FetchSetupPaymentMethod
    var fetchPaymentSetupStatus: FetchPaymentSetupStatus
    var fetchMissedPaymentData: FetchMissedPaymentData
    var chargeOutstandingPaymentClosure: ChargeOutstandingPayment
    var setDefaultPaymentMethodClosure: SetDefaultPaymentMethod
    var removePaymentMethodClosure: RemovePaymentMethod

    var setupTypes = [PaymentMethodSetupType]()
    var lastSetupType: PaymentMethodSetupType? { setupTypes.last }
    var removedProviders = [PaymentProvider]()

    enum Event {
        case getPaymentData
        case getPaymentStatusData
        case getPaymentHistoryData
        case setupPaymentMethod
        case getPaymentSetupStatus
        case getMissedPaymentData
        case chargeOutstandingPayment
        case setDefaultPaymentMethod
        case removePaymentMethod
    }

    init(
        fetchPaymentData: @escaping FetchPaymentData,
        fetchPaymentStatusData: @escaping FetchPaymentStatusData,
        fetchPaymentHistoryData: @escaping FetchPaymentHistoryData,
        fetchSetupPaymentMethod: @escaping FetchSetupPaymentMethod,
        fetchPaymentSetupStatus: @escaping FetchPaymentSetupStatus,
        fetchMissedPaymentData: @escaping FetchMissedPaymentData,
        chargeOutstandingPayment: @escaping ChargeOutstandingPayment,
        setDefaultPaymentMethod: @escaping SetDefaultPaymentMethod,
        removePaymentMethod: @escaping RemovePaymentMethod = {}
    ) {
        self.fetchPaymentData = fetchPaymentData
        self.fetchPaymentStatusData = fetchPaymentStatusData
        self.fetchPaymentHistoryData = fetchPaymentHistoryData
        self.fetchSetupPaymentMethod = fetchSetupPaymentMethod
        self.fetchPaymentSetupStatus = fetchPaymentSetupStatus
        self.fetchMissedPaymentData = fetchMissedPaymentData
        self.chargeOutstandingPaymentClosure = chargeOutstandingPayment
        self.setDefaultPaymentMethodClosure = setDefaultPaymentMethod
        self.removePaymentMethodClosure = removePaymentMethod
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
        setupTypes.append(type)
        let data = try await fetchSetupPaymentMethod()
        return data
    }

    func getPaymentSetupStatus(orderId: String) async throws -> PaymentSetupResult.PaymentSetupStatus {
        events.append(.getPaymentSetupStatus)
        let status = try await fetchPaymentSetupStatus()
        return status
    }

    func getMissedPaymentData() async throws -> MissedPaymentData? {
        events.append(.getMissedPaymentData)
        let data = try await fetchMissedPaymentData()
        return data
    }

    func chargeOutstandingPayment() async throws {
        events.append(.chargeOutstandingPayment)
        try await chargeOutstandingPaymentClosure()
    }

    func setDefaultPaymentMethod(_ method: PaymentMethod) async throws {
        events.append(.setDefaultPaymentMethod)
        try await setDefaultPaymentMethodClosure()
    }

    func removePaymentMethod(_ provider: PaymentProvider) async throws {
        events.append(.removePaymentMethod)
        removedProviders.append(provider)
        try await removePaymentMethodClosure()
    }
}

extension PaymentMethodSetupType {
    var phoneNumber: String? {
        switch self {
        case let .swishPayin(phoneNumber), let .swishPayout(phoneNumber):
            return phoneNumber
        case .trustly, .nordeaPayout:
            return nil
        }
    }
}
