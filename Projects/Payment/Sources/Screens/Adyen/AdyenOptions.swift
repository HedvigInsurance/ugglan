import Adyen
import Foundation
import hGraphQL

public struct AdyenOptions: Codable, Equatable {
    let paymentMethods: PaymentMethods
    //    let clientEncrytionKey: String

    init?(_ data: OctopusGraphQL.AvailablePaymentMethods2Query.Data?) {
        guard
            let paymentMethodsData = data?.availablePaymentMethods2.paymentMethodsResponse.data(using: .utf8),
            let paymentMethods = try? JSONDecoder()
                .decode(PaymentMethods.self, from: paymentMethodsData)
        else { return nil }

        self.paymentMethods = paymentMethods
        //        self.clientEncrytionKey = publicKey
    }
}

extension PaymentMethods: Encodable, Equatable {
    public static func == (lhs: Adyen.PaymentMethods, rhs: Adyen.PaymentMethods) -> Bool {
        return false
    }

    public func encode(to encoder: Encoder) throws {

    }

}
