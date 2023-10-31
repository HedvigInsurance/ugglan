import Apollo
import Contracts
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PaymentState: StateProtocol {
    var paymentData: PaymentData?
    public var paymentStatusData: PaymentStatusData? = nil
    var paymentConnectionID: String? = nil
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setPaymentData(data: PaymentData)
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case connectPayments
    case setConnectionID(id: String)
    case openHistory
    case openConnectBankAccount
    case openUrl
    case goBack
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PaymentDataQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue({ data in
                        let paymentData = PaymentData(data)
                        callback(.value(.setPaymentData(data: paymentData)))
                    })
                    .onError({ error in
                        self.setError(error.localizedDescription, for: .getPaymentData)
                    })
                return disposeBag
            }
        case .fetchPaymentStatus:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.PaymentInformationQuery(),
                        cachePolicy: .fetchIgnoringCacheCompletely
                    )
                    .onValue({ data in
                        let paymentStatus = PaymentStatusData(data: data)
                        callback(.value(.setPaymentStatus(data: paymentStatus)))
                    })
                    .onError({ error in
                        self.setError(error.localizedDescription, for: .getPaymentStatus)
                    })
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) -> PaymentState {
        var newState = state

        switch action {
        case .load:
            setLoading(for: .getPaymentData)
        case let .setPaymentData(data):
            removeLoading(for: .getPaymentData)
            newState.paymentData = data
        case let .setConnectionID(id):
            newState.paymentConnectionID = id
        case .fetchPaymentStatus:
            setLoading(for: .getPaymentStatus)
        case let .setPaymentStatus(data):
            removeLoading(for: .getPaymentStatus)
            newState.paymentStatusData = data
        default:
            break
        }
        return newState
    }
}
