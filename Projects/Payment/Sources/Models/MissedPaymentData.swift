import hCore
import hCoreUI

public struct MissedPaymentData: Codable, Equatable, Sendable, Hashable {
    let paymentData: PaymentData
    let paymentChargeData: PaymentChargeData

    public init(paymentData: PaymentData, paymentChargeData: PaymentChargeData) {
        self.paymentData = paymentData
        self.paymentChargeData = paymentChargeData
    }
}

extension MissedPaymentData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        L10n.paymentsPaymentOverdueTitle
    }
}
