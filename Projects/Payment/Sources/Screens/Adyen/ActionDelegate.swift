import Adyen
import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

class ActionDelegate: NSObject, ActionComponentDelegate {
    typealias ResultHandler = (_ result: Flow.Result<Either<Void, Adyen.Action>>) -> Void

    @Inject var client: ApolloClient
    let onResult: ResultHandler

    init(onResult: @escaping ResultHandler) {
        self.onResult = onResult
    }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        guard
            let detailsJsonData = try? JSONEncoder().encode(data.details.encodable),
            let detailsJson = String(data: detailsJsonData, encoding: .utf8) else {
            return
        }

        client.perform(
            mutation: GraphQL.AdyenAdditionalPaymentDetailsMutation(
                req: "{\"details\": \(detailsJson), \"paymentData\": \"\(data.paymentData!)\"}"
            )
        ).onValue { data in
            if let component = component as? DismissableComponent {
                component.dismiss(true, completion: nil)
            }

            if data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseFinished != nil {
                self.onResult(.success(.make(())))
            } else if let data = data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseAction {
                guard let jsonData = data.action.data(using: .utf8) else {
                    return
                }
                guard let action = try? JSONDecoder().decode(Adyen.Action.self, from: jsonData) else {
                    return
                }

                self.onResult(.success(.make(action)))
            } else {
                self.onResult(.failure(AdyenError.action))
            }
        }
    }

    func didFail(with error: Error, from component: ActionComponent) {
        if let component = component as? DismissableComponent {
            component.dismiss(true, completion: nil)
        }

        if let error = error as? Adyen.ComponentError, error == .cancelled {
            // no op
        } else {
            onResult(.failure(error))
        }
    }
}
