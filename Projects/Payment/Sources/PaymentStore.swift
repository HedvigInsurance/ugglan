import Apollo
import Campaign
import Contracts
import Foundation
import PresentableStore
import hCore

public struct PaymentState: StateProtocol {
    public var paymentData: PaymentData?
    public var ongoingPaymentData: [PaymentData] = []
    public var paymentStatusData: PaymentStatusData? = nil
    var paymentHistory: [PaymentHistoryListData] = []
    var paymentConnectionID: String? = nil
    var schema: String?
    public init() {}
}

public enum PaymentAction: ActionProtocol {
    case load
    case setPaymentData(data: PaymentData?)
    case setOngoingPaymentData(data: [PaymentData])
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case getHistory
    case setHistory(to: [PaymentHistoryListData])
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
    case getHistory
}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var paymentService: hPaymentClient

    public override func effects(_ getState: @escaping () -> PaymentState, _ action: PaymentAction) async {
        switch action {
        case .load:
            do {
                let paymentData = try await self.paymentService.getPaymentData()
                self.send(.setPaymentData(data: paymentData.upcoming))
                self.send(.setOngoingPaymentData(data: paymentData.ongoing))
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
        case let .setOngoingPaymentData(data):
            newState.ongoingPaymentData = data
        case .fetchPaymentStatus:
            setLoading(for: .getPaymentStatus)
        case let .setPaymentStatus(data):
            removeLoading(for: .getPaymentStatus)
            newState.paymentStatusData = data
        case .getHistory:
            setLoading(for: .getHistory)
        case let .setHistory(data):
            removeLoading(for: .getHistory)
            newState.paymentHistory = data
        }
        return newState
    }
}
