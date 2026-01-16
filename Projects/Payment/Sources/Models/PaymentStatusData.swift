import Foundation
import hCore

public struct PaymentStatusData: Codable, Equatable, Sendable, Hashable {
    public var status: PayinMethodStatus
    public let paymentChargeData: PaymentChargeData?

    public init(
        status: PayinMethodStatus,
        paymentChargeData: PaymentChargeData?
    ) {
        self.status = status
        self.paymentChargeData = paymentChargeData
    }
}

public struct PaymentChargeData: Codable, Equatable, Sendable, Hashable {
    let paymentMethod: String?
    let bankName: String?
    let account: String?
    let mandate: String?
    let chargingDayInTheMonth: Int?

    public init(
        paymentMethod: String?,
        bankName: String?,
        account: String?,
        mandate: String?,
        chargingDayInTheMonth: Int?
    ) {
        self.paymentMethod = paymentMethod
        self.bankName = bankName
        self.account = account
        self.mandate = mandate
        self.chargingDayInTheMonth = chargingDayInTheMonth
    }
}

public enum PayinMethodStatus: Codable, Equatable, Sendable, Hashable {
    case active
    case noNeedToConnect
    case needsSetup
    case pending
    case contactUs(date: String)
    case unknown

    var connectButtonTitle: String {
        switch self {
        case .active, .pending:
            return L10n.myPaymentDirectDebitReplaceButton
        case .needsSetup, .unknown, .noNeedToConnect, .contactUs:
            return L10n.myPaymentDirectDebitButton
        }
    }

    public var showConnectPayment: Bool {
        switch self {
        case .needsSetup:
            return true
        case .noNeedToConnect, .pending, .active, .unknown, .contactUs:
            return false
        }
    }
}
