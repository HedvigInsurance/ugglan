import Adyen
import AdyenComponents
import AdyenNetworking
import Foundation
import hGraphQL

public struct HedvigAdyenAPIContext {
    public var environment: AnyAPIEnvironment {
        switch hGraphQL.Environment.current {
        case .production: return Environment.live
        case .staging: return Environment.test
        case .custom: return Environment.test
        }
    }

    public var clientKey: String {
        switch hGraphQL.Environment.current {
        case .production:
            return "live_QQ6EHZ54DZBBTDBYLI4HWOAHM4MQFFI7"
        case .staging: return "test_XDVQHYGO5VAVTF46OIDAQILZOQQGGTAT"
        case .custom: return "test_XDVQHYGO5VAVTF46OIDAQILZOQQGGTAT"
        }
    }

    public var apiContext: APIContext { return .init(environment: environment, clientKey: clientKey) }
    public init() {}
}

internal final class EmptyPaymentComponent: PaymentComponent {
    var apiContext: APIContext { HedvigAdyenAPIContext().apiContext }
    internal let paymentMethod: PaymentMethod

    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?

    internal init(paymentMethod: PaymentMethod) { self.paymentMethod = paymentMethod }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    internal func initiatePayment() {
        let details = InstantPaymentDetails(type: paymentMethod.type)
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil))
    }
}
