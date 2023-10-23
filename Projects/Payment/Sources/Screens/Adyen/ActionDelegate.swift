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
    @Inject var octopus: hOctopus

    let onResult: ResultHandler

    init(onResult: @escaping ResultHandler) { self.onResult = onResult }

    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        let additionalDetails = AdditionalDetailsRequest(
            details: data.details.encodable,
            paymentData: data.paymentData
        )
        guard let detailsJsonData = try? JSONEncoder().encode(additionalDetails.details),
            let adyenParesWithMd = try? JSONDecoder().decode(AdyenParesWithMd.self, from: detailsJsonData)
        else { return }
        let req = OctopusGraphQL.SubmitAdyenRedirectionRequest(md: adyenParesWithMd.md, pares: adyenParesWithMd.pares)
        let mutation = OctopusGraphQL.SubmitAdyenRedirection2Mutation(req: req)
        octopus.client
            .perform(mutation: mutation)
            .onValue { data in
                if ["pending", "authorised"]
                    .contains(
                        data.submitAdyenRedirection2.resultCode.lowercased()
                    )
                {
                    self.onResult(.success(.make(())))
                } else if let jsonData = data.submitAdyenRedirection2.resultCode.data(using: .utf8),
                    let action = try? JSONDecoder().decode(AdyenActions.Action.self, from: jsonData)
                {
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

struct AdyenParesWithMd: Codable {
    let md: String
    let pares: String

    enum CodingKeys: String, CodingKey {
        case md = "MD"
        case pares = "PaRes"
    }
}
