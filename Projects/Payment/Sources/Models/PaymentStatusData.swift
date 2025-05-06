import Foundation
import hCore

public struct PaymentStatusData: Codable, Equatable, Sendable {
    public var status: PayinMethodStatus = .active
    let displayName: String?
    let descriptor: String?

    public init(
        status: PayinMethodStatus,
        displayName: String?,
        descriptor: String?
    ) {
        self.status = status
        self.displayName = displayName
        self.descriptor = descriptor
    }
}

public enum PayinMethodStatus: Equatable, Sendable {
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

extension PayinMethodStatus: Codable {}
