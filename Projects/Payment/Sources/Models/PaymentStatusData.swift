import Foundation
import hCore
import hGraphQL

public struct PaymentStatusData: Codable, Equatable {
    public var status: PayinMethodStatus = .active
    let displayName: String?
    let descriptor: String?

    init(
        status: PayinMethodStatus,
        displayName: String?,
        descriptor: String?
    ) {
        self.status = status
        self.displayName = displayName
        self.descriptor = descriptor
    }
}

extension GraphQLEnum<OctopusGraphQL.MemberPaymentConnectionStatus> {
    var asPayinMethodStatus: PayinMethodStatus {
        switch self {
        case .case(let t):
            switch t {
            case .active:
                return .active
            case .pending:
                return .pending
            case .needsSetup:
                return .needsSetup
            }
        case .unknown:
            return .unknown
        }
    }
}

public enum PayinMethodStatus: Equatable {
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
