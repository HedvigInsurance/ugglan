import hCore
import hCoreUI

public struct MissedPaymentData: Codable, Equatable, Sendable, Hashable, Identifiable {
    public var id: String { paymentData.id }

    let paymentData: PaymentData
    let paymentMethodData: ConnectedPaymentMethod

    public init(paymentData: PaymentData, paymentMethodData: ConnectedPaymentMethod) {
        self.paymentData = paymentData
        self.paymentMethodData = paymentMethodData
    }
}

extension MissedPaymentData: TrackingViewNameProtocol {
    public var nameForTracking: String {
        L10n.paymentsPaymentOverdueTitle
    }
}
