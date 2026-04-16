import Foundation
import hCore

public struct PaymentStatusData: Codable, Equatable, Sendable, Hashable {
    public var status: PayinMethodStatus
    public let chargingDay: Int?
    public let defaultPayinMethod: PaymentMethodData?
    public let payinMethods: [PaymentMethodData]
    public let defaultPayoutMethod: PaymentMethodData?
    public let payoutMethods: [PaymentMethodData]
    private let availableMethods: [AvailablePaymentMethod]

    public init(
        status: PayinMethodStatus,
        chargingDay: Int?,
        defaultPayinMethod: PaymentMethodData?,
        payinMethods: [PaymentMethodData],
        defaultPayoutMethod: PaymentMethodData?,
        payoutMethods: [PaymentMethodData],
        availableMethods: [AvailablePaymentMethod]
    ) {
        self.status = status
        self.chargingDay = chargingDay
        self.payinMethods = payinMethods
        self.payoutMethods = payoutMethods
        self.availableMethods = availableMethods
        self.defaultPayinMethod = defaultPayinMethod
        self.defaultPayoutMethod = defaultPayoutMethod
    }

    var availablePayoutMethods: [AvailablePaymentMethod] {
        availableMethods.filter({ $0.supportsPayout })
    }

    var showPayinSection: Bool {
        !payinMethods.isEmpty || defaultPayinMethod != nil
    }

    var showPayoutSection: Bool {
        (!availablePayoutMethods.isEmpty || defaultPayoutMethod != nil) && showPayinSection
    }
}

extension Sequence where Element == PaymentMethodData {
    var hasMethodInProgress: Bool {
        !self.filter({ $0.status == .pending }).isEmpty
    }
}

public struct PaymentMethodData: Codable, Equatable, Sendable, Hashable, Identifiable {
    public let id: String
    public let provider: PaymentProvider
    public let status: PaymentMethodStatus
    public let isDefault: Bool
    public let details: PaymentMethodDetails?

    public init(
        id: String,
        provider: PaymentProvider,
        status: PaymentMethodStatus,
        isDefault: Bool,
        details: PaymentMethodDetails?
    ) {
        self.id = id
        self.provider = provider
        self.status = status
        self.isDefault = isDefault
        self.details = details
    }
}

public enum PaymentMethodStatus: Codable, Equatable, Sendable, Hashable {
    case active
    case pending
    case unknown
}

public enum PaymentProvider: Codable, Equatable, Sendable, Hashable {
    case trustly
    case swish
    case nordea
    case invoice
    case unknown
}

public enum PaymentMethodDetails: Codable, Equatable, Sendable, Hashable {
    case invoice(delivery: InvoiceDelivery, email: String?)
    case swish(phoneNumber: String)
    case bankAccount(account: String, bank: String)

    public enum InvoiceDelivery: Codable, Equatable, Sendable, Hashable {
        case kivra
        case mail
        case unknown
    }
}

public struct AvailablePaymentMethod: Codable, Equatable, Sendable, Hashable {
    public let provider: PaymentProvider
    public let supportsPayin: Bool
    public let supportsPayout: Bool

    public init(
        provider: PaymentProvider,
        supportsPayin: Bool,
        supportsPayout: Bool
    ) {
        self.provider = provider
        self.supportsPayin = supportsPayin
        self.supportsPayout = supportsPayout
    }
}

public enum PaymentMethodSetupType: Sendable {
    case trustly(setAsDefaultPayin: Bool, setAsDefaultPayout: Bool)
}

public struct PaymentSetupResult: Codable, Equatable, Sendable {
    public let status: PaymentSetupStatus
    public let url: String?
    public let errorMessage: String?

    public init(status: PaymentSetupStatus, url: String?, errorMessage: String?) {
        self.status = status
        self.url = url
        self.errorMessage = errorMessage
    }

    public enum PaymentSetupStatus: Codable, Equatable, Sendable {
        case active
        case pending
        case failed
        case unknown
    }
}

extension PaymentProvider {
    public static func from(providerString: String?) -> PaymentProvider {
        guard let provider = providerString?.lowercased() else { return .unknown }
        if provider == "kivra" || provider == "invoice" {
            return .invoice
        } else if provider.hasPrefix("trustly") {
            return .trustly
        } else if provider == "swish" {
            return .swish
        } else if provider == "nordea" {
            return .nordea
        } else {
            return .unknown
        }
    }

    public func infoText(for dueDate: String) -> String? {
        switch self {
        case .trustly: L10n.paymentsPaymentDueInfo(dueDate)
        case .invoice: L10n.kivraPaymentInfo
        default: nil
        }
    }

    public var infoText: String? {
        switch self {
        case .trustly: L10n.paymentsPaymentDetailsInfoDescription
        case .invoice: L10n.kivraPaymentInfo
        default: nil
        }
    }

    public var paymentMethodLabel: String? {
        switch self {
        case .trustly: L10n.paymentsAutogiroLabel
        case .invoice: L10n.paymentsInvoice
        case .swish, .nordea, .unknown: nil
        }
    }

    public var infoTextForPendingStatus: String? {
        switch self {
        case .trustly: L10n.paymentsInProgress
        case .invoice: L10n.paymentsInProgressKivra
        case .swish, .nordea, .unknown: nil
        }
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
