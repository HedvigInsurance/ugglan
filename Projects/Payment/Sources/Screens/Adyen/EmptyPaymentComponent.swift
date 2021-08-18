import Adyen
import Foundation

internal final class EmptyPaymentComponent: PaymentComponent {
    internal let paymentMethod: PaymentMethod

    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?

    internal init(paymentMethod: PaymentMethod) { self.paymentMethod = paymentMethod }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    internal func initiatePayment() {
        let details = EmptyPaymentDetails(type: paymentMethod.type)
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
