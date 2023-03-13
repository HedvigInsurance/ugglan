import Adyen
import AdyenActions
import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AdyenMethodsList {
    static var payOutOptions: Future<AdyenOptions> {
        let client: ApolloClient = Dependencies.shared.resolve()
        return client.fetch(query: GiraffeGraphQL.AdyenAvailableMethodsQuery())
            .compactMap { data in
                guard
                    let paymentMethodsData = data.availablePayoutMethods.paymentMethodsResponse
                        .data(using: .utf8),
                    let paymentMethods = try? JSONDecoder()
                        .decode(PaymentMethods.self, from: paymentMethodsData)
                else { return nil }

                return AdyenOptions(
                    paymentMethods: paymentMethods,
                    clientEncrytionKey: data.adyenPublicKey
                )
            }
    }
}

struct AdyenPayOut: Presentable {
    @Inject var giraffe: hGiraffe
    let adyenOptions: AdyenOptions
    let urlScheme: String

    func materialize() -> (UIViewController, FiniteSignal<Bool>) {
        let (viewController, result) = AdyenMethodsList(adyenOptions: adyenOptions) { data, _, onResult in
            guard let jsonData = try? JSONEncoder().encode(data.paymentMethod.encodable),
                let json = String(data: jsonData, encoding: .utf8)
            else { return }

            self.giraffe.client
                .perform(
                    mutation: GiraffeGraphQL.AdyenTokenizePayoutDetailsMutation(
                        request: GiraffeGraphQL.TokenizationRequest(
                            paymentMethodDetails: json,
                            channel: .ios,
                            returnUrl: "\(urlScheme)://adyen"
                        )
                    )
                )
                .onValue { data in
                    if data.tokenizePayoutDetails?.asTokenizationResponseFinished != nil {
                        onResult(.success(.make(())))
                    } else if let data = data.tokenizePayoutDetails?.asTokenizationResponseAction {
                        guard let jsonData = data.action.data(using: .utf8) else { return }
                        guard
                            let action = try? JSONDecoder()
                                .decode(AdyenActions.Action.self, from: jsonData)
                        else { return }

                        onResult(.success(.make(action)))
                    } else {
                        onResult(.failure(AdyenError.tokenization))
                    }
                }
        } onSuccess: {
            giraffe.store.update(query: GiraffeGraphQL.ActivePayoutMethodsQuery()) {
                (data: inout GiraffeGraphQL.ActivePayoutMethodsQuery.Data) in
                data.activePayoutMethods = .init(status: .pending)
            }
        }
        .materialize()

        viewController.title = L10n.adyenPayoutTitle

        return (viewController, result)
    }
}

extension AdyenPayOut {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool) -> Next
    ) -> some JourneyPresentation {
        Journey(self) { success in
            next(success)
        }
    }
}
