import Foundation
import hCore
import hGraphQL

public struct PaymentStatusData: Codable, Equatable {
    public var status: PayinMethodStatus = .active
    public var failedCharges: Int?  //TODO: FIX this
    public var nextChargeDate: String?  //TODO: FIX this
    let displayName: String?
    let descriptor: String?

    init(data: OctopusGraphQL.PaymentInformationQuery.Data) {
        self.status = data.currentMember.paymentInformation.status.asPayinMethodStatus
        self.displayName = data.currentMember.paymentInformation.connection?.displayName
        self.descriptor = data.currentMember.paymentInformation.connection?.descriptor
        let statusOfFirstChargeHistory = data.currentMember.chargeHistory.first?.status
        if statusOfFirstChargeHistory == .failed {
            if let indexOfFirstSuccessCharge = data.currentMember.chargeHistory.firstIndex(where: {
                $0.status == .success
            }) {
                failedCharges = indexOfFirstSuccessCharge
            } else {
                failedCharges = data.currentMember.chargeHistory.count
            }
        } else {
            self.failedCharges = nil
        }

        self.nextChargeDate = data.currentMember.upcomingCharge?.date
    }

    var getNeedSetupInfoMessage: String? {
        if status == .needsSetup {
            if let failedCharges = self.failedCharges,
                let nextChargeDate = self.nextChargeDate
            {
                return L10n.paymentsLatePaymentsMessage(failedCharges, nextChargeDate)
            } else {
                return L10n.InfoCardMissingPayment.body
            }
        }
        return nil
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
}

extension PayinMethodStatus: Codable {}
