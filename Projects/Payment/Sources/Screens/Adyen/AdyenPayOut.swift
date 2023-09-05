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
    static var payOutOptions: Future<AdyenOptions?> {
        let giraffe: hGiraffe = Dependencies.shared.resolve()
        return giraffe.client.fetch(query: GiraffeGraphQL.AdyenAvailableMethodsQuery())
            .compactMap { data in
                return AdyenOptions(data)
            }
    }
}

public struct AdyenPayOut: Presentable {
    @Inject var giraffe: hGiraffe
    public let adyenOptions: AdyenOptions
    public let urlScheme: String

    public init(adyenOptions: AdyenOptions, urlScheme: String) {
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
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(.setActivePayout(data: .init(status: .pending)))
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
