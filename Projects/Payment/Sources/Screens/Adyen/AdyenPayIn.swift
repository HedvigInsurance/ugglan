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
        let giraffe: hGiraffe = Dependencies.shared.resolve()
        return giraffe.client.fetch(query: GiraffeGraphQL.AdyenAvailableMethodsQuery())
            .compactMap { data in
                return AdyenOptions(data)
            }
    }
}

public struct AdyenPayIn: Presentable {
    @PresentableStore var paymentStore: PaymentStore

    @Inject var giraffe: hGiraffe
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

            self.giraffe.client
                .perform(
                    mutation: GiraffeGraphQL.AdyenTokenizePaymentDetailsMutation(
                        input: GiraffeGraphQL.ConnectPaymentInput(
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
                            let store: PaymentStore = globalPresentableStoreContainer.get()
                            store.send(.fetchActivePayment)
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
            giraffe.store.withinReadWriteTransaction { transaction in
                try? transaction.update(query: GiraffeGraphQL.PayInMethodStatusQuery()) {
                    (data: inout GiraffeGraphQL.PayInMethodStatusQuery.Data) in
                    data.payinMethodStatus = .active
                }
            }

            paymentStore.send(.fetchPayInMethodStatus)

            // refetch to refresh UI
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                paymentStore.send(.fetchActivePayment)
            }
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
