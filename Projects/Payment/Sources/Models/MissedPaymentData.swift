import hCore
import hCoreUI

public struct MissedPaymentData: Codable, Equatable, Sendable, Hashable, Identifiable {
    public var id: String { paymentData.id }

    let paymentData: PaymentData
    let paymentMethodData: PaymentMethodData

    public init(paymentData: PaymentData, paymentMethodData: PaymentMethodData) {
        self.paymentData = paymentData
        self.paymentMethodData = paymentMethodData
    }
}

extension MissedPaymentData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        L10n.paymentsPaymentOverdueTitle
    }
}
