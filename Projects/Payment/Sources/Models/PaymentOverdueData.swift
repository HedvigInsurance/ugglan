import hCore
import hCoreUI

public struct PaymentOverdueData: Codable, Equatable, Sendable, Hashable {
    let paymentData: PaymentData
    let paymentChargeData: PaymentChargeData
}

extension PaymentOverdueData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        L10n.paymentsPaymentOverdueTitle
    }
}
