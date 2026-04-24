import Apollo
import Foundation
import PresentableStore
import hCore

public struct PaymentState: StateProtocol {
    public var paymentData: PaymentData?
    public var ongoingPaymentData: [PaymentData] = []
    public var paymentStatusData: PaymentStatusData?
    var paymentHistory: [PaymentHistoryListData] = []
    var paymentOverdueData: PaymentOverdueData?
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
    case setPaymentOverdueData(data: PaymentOverdueData?)
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
    case getHistory
}

public final class PaymentStore: LoadingStateStore<PaymentState, PaymentAction, LoadingAction> {
    @Inject var paymentService: hPaymentClient

    override public func effects(_: @escaping () -> PaymentState, _ action: PaymentAction) async {
        switch action {
        case .load:
            do {
                let payment = try await paymentService.getPaymentData()
                await sendAsync(.setPaymentData(data: payment.upcoming))
                await sendAsync(.setOngoingPaymentData(data: payment.ongoing))
                await setPaymentOverdueData()
            } catch {
                setError(L10n.General.errorBody, for: .getPaymentData)
            }
        case .fetchPaymentStatus:
            do {
                let statusData = try await paymentService.getPaymentStatusData()
                await sendAsync(.setPaymentStatus(data: statusData))
                await setPaymentOverdueData()
            } catch {
                setError(L10n.General.errorBody, for: .getPaymentStatus)
            }
        case .getHistory:
            do {
                let data = try await paymentService.getPaymentHistoryData()
                await sendAsync(.setHistory(to: data))
                await setPaymentOverdueData()
            } catch {
                setError(L10n.General.errorBody, for: .getHistory)
            }
        default:
            break
        }
    }

    override public func reduce(_ state: PaymentState, _ action: PaymentAction) async -> PaymentState {
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
        case let .setPaymentOverdueData(data):
            newState.paymentOverdueData = data
        }
        return newState
    }

    /// Determines whether to show the overdue payment card for Trustly users.
    /// Checks that the user pays via Trustly, has at least one outstanding contract period,
    /// and has a failed payment in their history. If all conditions are met, dispatches
    /// the first failed historical payment data so the UI can render the overdue card.
    private func setPaymentOverdueData() async {
        let upcomingData = state.paymentData
        let historyData = state.paymentHistory
        let statusData = state.paymentStatusData
        guard let upcomingData, let statusData else { return }
        guard statusData.paymentChargeData?.chargeMethod == .trustly else { return }
        let hasOutstandingPeriod = upcomingData.contracts.contains { contract in
            contract.periods.contains { $0.isOutstanding }
        }
        guard hasOutstandingPeriod else { return }
        guard
            let firstOutstadingPaymentData = historyData.lazy
                .flatMap({ $0.valuesPerMonth })
                .first(where: { $0.paymentData.status.hasFailed })?
                .paymentData
        else { return }
        await sendAsync(.setPaymentOverdueData(data: firstOutstadingPaymentData))
    }
}
