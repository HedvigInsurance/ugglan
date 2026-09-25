import Foundation
import hCore

public struct PaymentStatusData: Codable, Equatable, Sendable, Hashable {
    public var status: PayinMethodStatus
    let chargingDay: Int?
    private let defaultPayinMethod: ConnectedPaymentMethod?
    let payinMethods: [ConnectedPaymentMethod]
    private let defaultPayoutMethod: ConnectedPaymentMethod?
    let payoutMethods: [ConnectedPaymentMethod]
    public let availableMethods: [AvailablePaymentMethod]
    public let missingConnection: MissingPaymentConnection?
    public let layout: PaymentLayout

    public init(
        status: PayinMethodStatus,
        chargingDay: Int?,
        defaultPayinMethod: ConnectedPaymentMethod?,
        payinMethods: [ConnectedPaymentMethod],
        defaultPayoutMethod: ConnectedPaymentMethod?,
        payoutMethods: [ConnectedPaymentMethod],
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

    var availablePayinMethods: [AvailablePaymentMethod] {
        availableMethods.filter((\.supportsPayin))
    }

    var hasAnyPayoutMethod: Bool {
        !availablePayoutMethods.isEmpty || defaultOrFirstDefaultPayoutMethod != nil
    }

    var hasAnyPayinMethod: Bool {
        !payinMethods.isEmpty || defaultOrFirstDefaultPayinMethod != nil
    }

    public var defaultOrFirstDefaultPayoutMethod: ConnectedPaymentMethod? {
        defaultPayoutMethod ?? payoutMethods.first(where: (\.isDefault))
    }

    public var defaultOrFirstDefaultPayinMethod: ConnectedPaymentMethod? {
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

extension Sequence where Element == ConnectedPaymentMethod {
    var hasMethodInProgress: Bool {
        !self.filter({ $0.status == .pending && $0.isDefault == true }).isEmpty
    }
}

public struct ConnectedPaymentMethod: Codable, Equatable, Sendable, Hashable, Identifiable {
    public var id: String {
        provider.asString + status.asString
    }
    public let status: PaymentMethodStatus
    public let isDefault: Bool
    public let method: PaymentMethod

    public var provider: PaymentProvider {
        method.provider
    }

    public init(
        status: PaymentMethodStatus,
        isDefault: Bool,
        method: PaymentMethod
    ) {
        self.status = status
        self.isDefault = isDefault
        self.method = method
    }
}

public enum PaymentMethodStatus: Codable, Equatable, Sendable, Hashable {
    case active
    case pending
    case unknown
}

public enum PaymentProvider: Codable, Equatable, Sendable, Hashable, Identifiable, CaseIterable {
    public var id: String {
        self.asString
    }
    case trustly
    case swish
    case nordea
    case invoice
    case unknown
}

public enum PaymentMethod: Codable, Equatable, Sendable, Hashable {
    case trustly(bankAccount: BankAccount?)
    case nordea(bankAccount: BankAccount?)
    case swish(phoneNumber: String?)
    case invoice(delivery: InvoiceDelivery?)
    case unknown

    public struct BankAccount: Codable, Equatable, Sendable, Hashable {
        public let account: String
        public let bank: String

        public init(account: String, bank: String) {
            self.account = account
            self.bank = bank
        }
    }

    public enum InvoiceDelivery: Codable, Equatable, Sendable, Hashable {
        case kivra
        case email(String?)
        case unknown
    }

    public var provider: PaymentProvider {
        switch self {
        case .trustly: .trustly
        case .nordea: .nordea
        case .swish: .swish
        case .invoice: .invoice
        case .unknown: .unknown
        }
    }

    /// The bank account behind the methods that have one, so callers don't repeat the
    /// `.trustly`/`.nordea` pattern match every time they only need the account or the bank.
    public var bankAccount: BankAccount? {
        switch self {
        case .trustly(let bankAccount), .nordea(let bankAccount): bankAccount
        case .swish, .invoice, .unknown: nil
        }
    }

    public init(provider: PaymentProvider) {
        switch provider {
        case .trustly: self = .trustly(bankAccount: nil)
        case .nordea: self = .nordea(bankAccount: nil)
        case .swish: self = .swish(phoneNumber: nil)
        case .invoice: self = .invoice(delivery: nil)
        case .unknown: self = .unknown
        }
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

public enum MissingPaymentConnection: Codable, Equatable, Sendable, Hashable {
    case payin
    case payout
}

public enum PayinMethodStatus: Codable, Equatable, Sendable, Hashable {
    case active
    case noNeedToConnect
    case needsSetup
    case pending
    case terminatingDueToMissedPayments(date: String)
    case unknown

    var connectButtonTitle: String {
        switch self {
        case .active, .pending:
            return L10n.myPaymentDirectDebitReplaceButton
        case .needsSetup, .unknown, .noNeedToConnect, .terminatingDueToMissedPayments:
            return L10n.myPaymentDirectDebitButton
        }
    }
}
