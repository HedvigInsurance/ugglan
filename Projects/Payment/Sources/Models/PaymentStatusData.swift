import Foundation
import hCore
import hGraphQL

public struct PaymentStatusData: Codable, Equatable {
    public var status: PayinMethodStatus = .active
    public var nextChargeDate: ServerBasedDate?  //TODO: FIX this
    let displayName: String?
    let descriptor: String?

    init(
        status: PayinMethodStatus,
        nextChargeDate: String?,
        displayName: String?,
        descriptor: String?
    ) {
        self.status = status
        self.nextChargeDate = nextChargeDate
        self.displayName = displayName
        self.descriptor = descriptor
    }

    init(data: OctopusGraphQL.PaymentInformationQuery.Data) {
        self.status = data.currentMember.paymentInformation.status.asPayinMethodStatus
        self.displayName = data.currentMember.paymentInformation.connection?.displayName
        self.descriptor = data.currentMember.paymentInformation.connection?.descriptor
        self.nextChargeDate = data.currentMember.futureCharge?.date
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
        case .unknown(let string):
            return .unknown
        }
    }
}

public enum PayinMethodStatus {
    case active
    case needsSetup
    case pending
    case unknown

    var connectButtonTitle: String {
        switch self {
        case .active, .pending:
            return L10n.myPaymentDirectDebitReplaceButton
        case .needsSetup, .unknown:
            return L10n.myPaymentDirectDebitButton
        }
    }
}

extension PayinMethodStatus: Codable {}
