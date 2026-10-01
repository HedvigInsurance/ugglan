import Foundation
import hCore

@testable import Payment

/// Placeholder endpoints the payment mocks hand back in place of a real provider URL.
enum PaymentTestURL {
    static let setup = "https://example.com/setup"
    static let retry = "https://example.com/retry"
}

enum PaymentTestMethod {
    static let trustly = PaymentMethod.trustly(bankAccount: .init(account: "1234", bank: "Bank"))
    static let swish = PaymentMethod.swish(phoneNumber: "0735328847")
    static let invoice = PaymentMethod.invoice(delivery: .kivra)
}

extension PaymentMethod {
    func connected(status: PaymentMethodStatus = .active, isDefault: Bool = false) -> ConnectedPaymentMethod {
        .init(status: status, isDefault: isDefault, method: self)
    }
}

extension PaymentStatusData {
    static func test(
        status: PayinMethodStatus = .active,
        chargingDay: Int? = 27,
        defaultPayinMethod: ConnectedPaymentMethod? = nil,
        payinMethods: [ConnectedPaymentMethod] = [],
        defaultPayoutMethod: ConnectedPaymentMethod? = nil,
        payoutMethods: [ConnectedPaymentMethod] = [],
        availableMethods: [AvailablePaymentMethod] = [],
        missingConnection: MissingPaymentConnection? = nil,
        layout: PaymentLayout = .other,
        memberPhoneNumber: String? = nil
    ) -> PaymentStatusData {
        .init(
            status: status,
            chargingDay: chargingDay,
            defaultPayinMethod: defaultPayinMethod,
            payinMethods: payinMethods,
            defaultPayoutMethod: defaultPayoutMethod,
            payoutMethods: payoutMethods,
            availableMethods: availableMethods,
            missingConnection: missingConnection,
            layout: layout,
            memberPhoneNumber: memberPhoneNumber
        )
    }
}

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
            .init(status: .pending, orderId: "order-1", url: PaymentTestURL.setup, errorMessage: nil)
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
        removePaymentMethod: @escaping RemovePaymentMethod
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

    func getPaymentSetupStatus(orderId _: String) async throws -> PaymentSetupResult.PaymentSetupStatus {
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

    func setDefaultPaymentMethod(_: PaymentMethod) async throws {
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
