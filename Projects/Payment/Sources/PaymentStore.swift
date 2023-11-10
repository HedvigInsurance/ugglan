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
    var paymentDiscountsData: PaymentDiscountsData?
    public var paymentStatusData: PaymentStatusData? = nil
    var paymentHistory: [PaymentHistoryListData] = []
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
    case fetchDiscountsData
    case setDiscountsData(data: PaymentDiscountsData)
    case setConnectionID(id: String)
    case navigation(to: PaymentNavigation)
    case getHistory
    case setHistory(to: [PaymentHistoryListData])
}

public enum PaymentNavigation: ActionProtocol {
    case openUrl
    case openHistory
    case openDiscounts
    case openConnectBankAccount
    case openConnectPayments
    case openPaymentDetails(data: PaymentData)
    case openInviteFriends(code: String, amount: String)
    case openChangeCode
    case openAddCampaing
    case openAllReferrals
    case openDeleteCampaing(discount: Discount)
    case goBack
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
    case getDiscountsData
    case getHistory
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
        case .fetchDiscountsData:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let data = try await self.paymentService.getPaymentDiscountsData()
                        callback(.value(.setDiscountsData(data: data)))
                    } catch {
                        self.setError(L10n.General.errorBody, for: .getDiscountsData)
                    }
                }
                return disposeBag
            }
        case .getHistory:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let data = try await self.paymentService.getPaymentHistoryData()
                        callback(.value(.setHistory(to: data)))
                    } catch {
                        self.setError(L10n.General.errorBody, for: .getHistory)
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
        case .fetchDiscountsData:
            setLoading(for: .getDiscountsData)
        case let .setDiscountsData(data):
            removeLoading(for: .getDiscountsData)
            newState.paymentDiscountsData = data
        case .getHistory:
            setLoading(for: .getHistory)
        case let .setHistory(data):
            removeLoading(for: .getHistory)
            newState.paymentHistory = data
        default:
            break
        }
        return newState
    }
}
