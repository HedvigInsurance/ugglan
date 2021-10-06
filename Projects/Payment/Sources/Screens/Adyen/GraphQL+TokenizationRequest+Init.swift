import Foundation
import hGraphQL

extension GraphQL.TokenizationRequest {
    init(
        json: String,
        urlScheme: String
    ) {
        self = GraphQL.TokenizationRequest(
            paymentMethodDetails: json.replacingOccurrences(of: "applepay.token", with: "applepayToken"),
            channel: .ios,
            returnUrl: "\(urlScheme)://adyen"
        )
    }
}
