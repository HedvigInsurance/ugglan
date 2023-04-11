import Adyen
import AdyenActions
import AdyenComponents
import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

struct AdditionalDetailsRequest: Encodable {
    let details: AnyEncodable
    let paymentData: String?
}

class ActionDelegate: NSObject, ActionComponentDelegate {
    typealias ResultHandler = (_ result: Flow.Result<Either<Void, AdyenActions.Action>>) -> Void

    @PresentableStore var store: PaymentStore
    @Inject var giraffe: hGiraffe
    let onResult: ResultHandler

    init(onResult: @escaping ResultHandler) { self.onResult = onResult }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let additionalDetails = AdditionalDetailsRequest(
            details: data.details.encodable,
            paymentData: data.paymentData
        )

        guard let detailsJsonData = try? JSONEncoder().encode(additionalDetails),
            let detailsJson = String(data: detailsJsonData, encoding: .utf8)
        else { return }

        giraffe.client
            .perform(
                mutation: GiraffeGraphQL.AdyenAdditionalPaymentDetailsMutation(
                    paymentConnectionID: store.state.paymentConnectionID ?? "",
                    req: detailsJson
                )
            )
            .onValue { data in
                if [.pending, .authorised]
                    .contains(
                        data.paymentConnectionSubmitAdditionalPaymentDetails.asConnectPaymentFinished?.status
                    ),
                    let paymentConnectionId = data.paymentConnectionSubmitAdditionalPaymentDetails
                        .asConnectPaymentFinished?
                        .paymentTokenId
                {
                    self.store.send(.setConnectionID(id: paymentConnectionId))
                    self.onResult(.success(.make(())))
                } else if let data = data.paymentConnectionSubmitAdditionalPaymentDetails.asActionRequired {
                    self.store.send(.setConnectionID(id: data.paymentTokenId))

                    guard let jsonData = data.actionV2.data(using: .utf8) else { return }
                    guard
                        let action = try? JSONDecoder()
                            .decode(AdyenActions.Action.self, from: jsonData)
                    else { return }

                    self.onResult(.success(.make(action)))
                } else {
                    self.onResult(.failure(AdyenError.action))
                }
            }
    }

    func didFail(with error: Error, from component: ActionComponent) {
        if let error = error as? Adyen.ComponentError, error == .cancelled {
            // no op
        } else {
            onResult(.failure(error))
        }
    }
    func didComplete(from component: ActionComponent) {}
}
