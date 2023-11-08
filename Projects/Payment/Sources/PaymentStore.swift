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
    var schema: String?
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setPaymentData(data: PaymentData?)
    case setSchema(schema: String)
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case setConnectionID(id: String)
    case navigation(to: PaymentNavigation)
}

public enum PaymentNavigation: ActionProtocol {
    case openUrl
    case openHistory
    case openConnectBankAccount
    case openConnectPayments
    case openPaymentDetails(data: PaymentData, withTitle: String)
    case goBack
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var paymentService: hPaymentService

    public override func effects(
        _ getState: @escaping () -> PaymentState,
        _ action: PaymentAction
    ) -> FiniteSignal<PaymentAction>? {
        switch action {
        case .load:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let paymentData = try await self.paymentService.getPaymentData()
                        callback(.value(.setPaymentData(data: paymentData)))
                    } catch {
                        self.setError(L10n.General.errorBody, for: .getPaymentData)
                    }
                }
                return disposeBag
            }
        case .fetchPaymentStatus:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let statusData = try await self.paymentService.getPaymentStatusData()
                        callback(.value(.setPaymentStatus(data: statusData)))
                    } catch {
                        self.setError(L10n.General.errorBody, for: .getPaymentStatus)
                    }
                }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) -> PaymentState {
        var newState = state

        switch action {
        case let .setSchema(schema):
            newState.schema = schema
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
