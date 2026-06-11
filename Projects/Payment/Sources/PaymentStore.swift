import Apollo
import Foundation
import PresentableStore
import hCore

public struct PaymentState: StateProtocol {
    public var paymentData: PaymentData?
    public var ongoingPaymentData: [PaymentData] = []
    public var paymentStatusData: PaymentStatusData?
    var paymentHistory: [PaymentHistoryListData] = []
    public internal(set) var missedPaymentData: MissedPaymentData?
    public init() {}

    var showsPayinSection: Bool {
        guard let paymentStatusData else { return false }
        switch paymentStatusData.layout {
        case .qasaOnly:
            return paymentData != nil
        case .other:
            return paymentStatusData.defaultOrFirstDefaultPayinMethod != nil
                && paymentStatusData.hasAnyPayinMethod
        }
    }

    var showsChangePayinMethod: Bool {
        guard let paymentStatusData else { return false }
        switch paymentStatusData.layout {
        case .qasaOnly: return paymentData != nil
        case .other: return paymentStatusData.hasAnyPayinMethod
        }
    }

    var showsPayoutSection: Bool {
        guard let paymentStatusData else { return false }
        switch paymentStatusData.layout {
        case .qasaOnly: return paymentStatusData.hasAnyPayoutMethod
        case .other: return paymentStatusData.hasAnyPayoutMethod && showsPayinSection
        }
    }

    var showsNoPaymentsInProgress: Bool {
        guard let paymentStatusData else { return false }
        return paymentStatusData.layout != .qasaOnly && paymentData == nil
    }

    var showsConnectPayment: Bool {
        guard let paymentStatusData, paymentStatusData.layout != .qasaOnly else { return false }
        return paymentStatusData.missingConnection == .payin
            || (paymentData != nil && paymentStatusData.defaultOrFirstDefaultPayinMethod == nil)
    }

    var showsConnectPayout: Bool {
        paymentStatusData?.missingConnection == .payout && !showsConnectPayment
    }
}

public enum PaymentAction: ActionProtocol {
    case load
    case setPaymentData(data: PaymentData?)
    case setOngoingPaymentData(data: [PaymentData])
    case fetchPaymentStatus
    case setPaymentStatus(data: PaymentStatusData)
    case getHistory
    case setHistory(to: [PaymentHistoryListData])
    case getMissedPayment
    case setMissedPaymentData(data: MissedPaymentData?)
}

public enum LoadingAction: LoadingProtocol {
    case getPaymentData
    case getPaymentStatus
    case getHistory
    case getMissedPayment
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
            } catch {
                setError(L10n.General.errorBody, for: .getPaymentData)
            }
        case .fetchPaymentStatus:
            do {
                let statusData = try await paymentService.getPaymentStatusData()
                await sendAsync(.setPaymentStatus(data: statusData))
            } catch {
                setError(L10n.General.errorBody, for: .getPaymentStatus)
            }
        case .getHistory:
            do {
                let data = try await paymentService.getPaymentHistoryData()
                await sendAsync(.setHistory(to: data))
            } catch {
                setError(L10n.General.errorBody, for: .getHistory)
            }
        case .getMissedPayment:
            do {
                let data = try await paymentService.getMissedPaymentData()
                await sendAsync(.setMissedPaymentData(data: data))
            } catch {
                await sendAsync(.setMissedPaymentData(data: nil))
                setError(L10n.General.errorBody, for: .getMissedPayment)
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
        case .getMissedPayment:
            setLoading(for: .getMissedPayment)
        case let .setMissedPaymentData(data):
            newState.missedPaymentData = data
            removeLoading(for: .getMissedPayment)
        }
        return newState
    }
}
