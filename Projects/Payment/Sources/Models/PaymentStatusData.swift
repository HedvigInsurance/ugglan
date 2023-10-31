import Foundation
import hCore
import hGraphQL

public struct PaymentStatusData: Codable, Equatable {
    public var status: PayinMethodStatus = .active
    public var nextChargeDate: String?  //TODO: FIX this
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
        let statusOfFirstChargeHistory = data.currentMember.chargeHistory.first?.status
        //        if statusOfFirstChargeHistory == .failed {
        //            if let indexOfFirstSuccessCharge = data.currentMember.chargeHistory.firstIndex(where: {
        //                $0.status == .success
        //            }) {
        //                failedCharges = indexOfFirstSuccessCharge
        //            } else {
        //                failedCharges = data.currentMember.chargeHistory.count
        //            }
        //        } else {
        //            self.failedCharges = nil
        //        }

        self.nextChargeDate = data.currentMember.upcomingCharge?.date
    }
}

extension OctopusGraphQL.MemberPaymentConnectionStatus {
    var asPayinMethodStatus: PayinMethodStatus {
        switch self {
        case .active:
            return .active
        case .pending:
            return .pending
        case .needsSetup:
            return .needsSetup
        case .__unknown:
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
