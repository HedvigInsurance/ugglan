import Adyen
import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

extension AdyenMethodsList {
    static var payInOptions: Future<AdyenOptions> {
        let client: ApolloClient = Dependencies.shared.resolve()
        return client.fetch(query: GraphQL.AdyenAvailableMethodsQuery())
            .compactMap { data in
                guard
                    let paymentMethodsData = data.availablePaymentMethods.paymentMethodsResponse.data(using: .utf8),
                    let paymentMethods = try? JSONDecoder().decode(PaymentMethods.self, from: paymentMethodsData)
                else {
                    return nil
                }

                return AdyenOptions(paymentMethods: paymentMethods, clientEncrytionKey: data.adyenPublicKey)
            }
    }
}

struct AdyenPayIn: Presentable {
    @Inject var client: ApolloClient
    let adyenOptions: AdyenOptions
    let urlScheme: String

    func materialize() -> (UIViewController, Future<Void>) {
        let (viewController, result) = AdyenMethodsList(adyenOptions: adyenOptions) { data, _, onResult in
            guard
                let jsonData = try? JSONEncoder().encode(data.paymentMethod.encodable),
                let json = String(data: jsonData, encoding: .utf8)
            else {
                return
            }

            self.client.perform(
                mutation: GraphQL.AdyenTokenizePaymentDetailsMutation(
                    request: GraphQL.TokenizationRequest(json: json, urlScheme: urlScheme)
                )
            ).onValue { data in
                if data.tokenizePaymentDetails?.asTokenizationResponseFinished != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        client.fetch(
                            query: GraphQL.ActivePaymentMethodsQuery(),
                            cachePolicy: .fetchIgnoringCacheData
                        ).onValue { _ in }
                    }
                    onResult(.success(.make(())))
                } else if let data = data.tokenizePaymentDetails?.asTokenizationResponseAction {
                    guard let jsonData = data.action.data(using: .utf8) else {
                        return
                    }
                    guard let action = try? JSONDecoder().decode(Adyen.Action.self, from: jsonData) else {
                        return
                    }

                    onResult(.success(.make(action)))
                } else {
                    onResult(.failure(AdyenError.tokenization))
                }
            }
        }.materialize()

        viewController.title = L10n.adyenPayinTitle

        return (viewController, result)
    }
}
