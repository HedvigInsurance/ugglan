import Foundation
import hCore

public struct PaymentStatusData: Codable, Equatable, Sendable, Hashable {
    public var status: PayinMethodStatus
    let chargingDay: Int?
    private let defaultPayinMethod: PaymentMethodData?
    let payinMethods: [PaymentMethodData]
    private let defaultPayoutMethod: PaymentMethodData?
    let payoutMethods: [PaymentMethodData]
    public let availableMethods: [AvailablePaymentMethod]
    public let missingConnection: MissingPaymentConnection?
    public let layout: PaymentLayout

    public init(
        status: PayinMethodStatus,
        chargingDay: Int?,
        defaultPayinMethod: PaymentMethodData?,
        payinMethods: [PaymentMethodData],
        defaultPayoutMethod: PaymentMethodData?,
        payoutMethods: [PaymentMethodData],
        availableMethods: [AvailablePaymentMethod],
        missingConnection: MissingPaymentConnection?,
        layout: PaymentLayout
    ) {
        self.status = status
        self.chargingDay = chargingDay
        self.payinMethods = payinMethods
        self.payoutMethods = payoutMethods
        self.availableMethods = availableMethods
        self.defaultPayinMethod = defaultPayinMethod
        self.defaultPayoutMethod = defaultPayoutMethod
        self.missingConnection = missingConnection
        self.layout = layout
    }

    var availablePayoutMethods: [AvailablePaymentMethod] {
        availableMethods.filter((\.supportsPayout))
    }

    var hasAnyPayoutMethod: Bool {
        !availablePayoutMethods.isEmpty || defaultOrFirstDefaultPayoutMethod != nil
    }

    var hasAnyPayinMethod: Bool {
        !payinMethods.isEmpty || defaultOrFirstDefaultPayinMethod != nil
    }

    public var defaultOrFirstDefaultPayoutMethod: PaymentMethodData? {
        defaultPayoutMethod ?? payoutMethods.first(where: (\.isDefault))
    }

    public var defaultOrFirstDefaultPayinMethod: PaymentMethodData? {
        defaultPayinMethod ?? payinMethods.first(where: (\.isDefault))
    }

    var showsHistoricalSections: Bool {
        layout != .qasaOnly
    }
}

/// Describes the member's contract mix, which drives the payments screen layout.
/// - `qasaOnly`: member has only Qasa-landlord agreements (payout-only flow, no history/discounts).
/// - `other`: member has at least one non-Qasa-landlord agreement (or no agreements).
public enum PaymentLayout: Codable, Equatable, Sendable, Hashable {
    case qasaOnly
    case other

    public init(contractTypes: [TypeOfContract]) {
        let hasLandlord = contractTypes.contains(.seQasaLandlord)
        let hasOther = contractTypes.contains(where: { $0 != .seQasaLandlord })
        self = (hasLandlord && !hasOther) ? .qasaOnly : .other
    }
}

extension Sequence where Element == PaymentMethodData {
    var hasMethodInProgress: Bool {
        !self.filter({ $0.status == .pending && $0.isDefault == true }).isEmpty
    }
}

extension PaymentMethodData {
    var info: String {
        switch self.details {
        case .bankAccount(let account, _):
            return "\(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return self.provider.payoutTitle
        case nil:
            return ""
        }
    }
}

public struct PaymentMethodData: Codable, Equatable, Sendable, Hashable, Identifiable {
    public var id: String {
        provider.asString + status.asString
    }
    public let provider: PaymentProvider
    public let status: PaymentMethodStatus
    public let isDefault: Bool
    public let details: PaymentMethodDetails?

    public init(
        provider: PaymentProvider,
        status: PaymentMethodStatus,
        isDefault: Bool,
        details: PaymentMethodDetails?
    ) {
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

public enum PaymentProvider: Codable, Equatable, Sendable, Hashable, Identifiable {
    public var id: String {
        self.asString
    }
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
    case trustly
    case nordeaPayout(accountNumber: String)
    case swishPayout(phoneNumber: String)
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

public enum MissingPaymentConnection: Codable, Equatable, Sendable, Hashable {
    case payin
    case payout
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
}
