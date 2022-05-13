import Adyen
import AdyenActions
import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AdyenMethodsList {
    static var payInOptions: Future<AdyenOptions> {
        let client: ApolloClient = Dependencies.shared.resolve()
        return client.fetch(query: GraphQL.AdyenAvailableMethodsQuery())
            .compactMap { data in
                guard
                    let paymentMethodsData = data.availablePaymentMethods.paymentMethodsResponse
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

public struct AdyenPayIn: Presentable {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    @PresentableStore var paymentStore: PaymentStore
    let adyenOptions: AdyenOptions
    let urlScheme: String

    public init(
        adyenOptions: AdyenOptions,
        urlScheme: String
    ) {
        self.adyenOptions = adyenOptions
        self.urlScheme = urlScheme
    }

    public func materialize() -> (UIViewController, FiniteSignal<Bool>) {
        let (viewController, result) = AdyenMethodsList(adyenOptions: adyenOptions) { data, _, onResult in
            guard let jsonData = try? JSONEncoder().encode(data.paymentMethod.encodable),
                let json = String(data: jsonData, encoding: .utf8)
            else { return }

            self.client
                .perform(
                    mutation: GraphQL.AdyenTokenizePaymentDetailsMutation(
                        input: GraphQL.ConnectPaymentInput(
                            paymentMethodDetails: json,
                            channel: .ios,
                            returnUrl: "\(urlScheme)://adyen",
                            market: Localization.Locale.currentLocale.market.graphQL
                        )
                    )
                )
                .onValue { data in
                    if let data = data.paymentConnectionConnectPayment.asConnectPaymentFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            client.fetch(
                                query: GraphQL.ActivePaymentMethodsQuery(),
                                cachePolicy: .fetchIgnoringCacheData
                            )
                            .sink()
                        }
                        paymentStore.send(.setConnectionID(id: data.paymentTokenId))
                        onResult(.success(.make(())))
                    } else if let data = data.paymentConnectionConnectPayment.asActionRequired {
                        guard let jsonData = data.actionV2.data(using: .utf8) else { return }
                        guard
                            let action = try? JSONDecoder()
                                .decode(AdyenActions.Action.self, from: jsonData)
                        else { return }

                        paymentStore.send(.setConnectionID(id: data.paymentTokenId))
                        onResult(.success(.make(action)))
                    } else {
                        onResult(.failure(AdyenError.tokenization))
                    }
                }
        } onSuccess: {
            store.withinReadWriteTransaction { transaction in
                try? transaction.update(query: GraphQL.PayInMethodStatusQuery()) {
                    (data: inout GraphQL.PayInMethodStatusQuery.Data) in
                    data.payinMethodStatus = .active
                }
            }

            // refetch to refresh UI
            Future().delay(by: 0.5)
                .flatMapResult { _ in client.fetch(query: GraphQL.ActivePaymentMethodsQuery()) }
                .sink()
        }
        .materialize()

        viewController.title = L10n.adyenPayinTitle
        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .connectPaymentAdyen))

        return (viewController, result)
    }
}

extension AdyenPayIn {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ success: Bool) -> Next
    ) -> some JourneyPresentation {
        Journey(self) { success in
            next(success)
        }
    }
}
