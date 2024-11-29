import Apollo
import Contracts
import Foundation
import PresentableStore
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
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case fetchDiscountsData
    case setDiscountsData(data: PaymentDiscountsData)
    case getHistory
    case setHistory(to: [PaymentHistoryListData])
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
    case getDiscountsData
    case getHistory
}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var paymentService: hPaymentClient

    public override func effects(_ getState: @escaping () -> PaymentState, _ action: PaymentAction) async {
        switch action {
        case .load:
            do {
                let paymentData = try await self.paymentService.getPaymentData()
                self.send(.setPaymentData(data: paymentData))
            } catch {
                self.setError(L10n.General.errorBody, for: .getPaymentData)
            }
        case .fetchPaymentStatus:
            do {
                let statusData = try await self.paymentService.getPaymentStatusData()
                self.send(.setPaymentStatus(data: statusData))
            } catch {
                self.setError(L10n.General.errorBody, for: .getPaymentStatus)
            }
        case .fetchDiscountsData:
            do {
                let data = try await self.paymentService.getPaymentDiscountsData()
                self.send(.setDiscountsData(data: data))
            } catch {
                self.setError(L10n.General.errorBody, for: .getDiscountsData)
            }
        case .getHistory:
            do {
                let data = try await self.paymentService.getPaymentHistoryData()
                self.send(.setHistory(to: data))
            } catch {
                self.setError(L10n.General.errorBody, for: .getHistory)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: PaymentState, _ action: PaymentAction) async -> PaymentState {
        var newState = state

        switch action {
        case .load:
            setLoading(for: .getPaymentData)
        case let .setPaymentData(data):
            removeLoading(for: .getPaymentData)
            newState.paymentData = data
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
        }
        return newState
    }
}
