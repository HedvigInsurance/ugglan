import AppStateContainer
import Foundation
import hCore

@MainActor
@PersistableStore
public final class PaymentStore: AppStore {
    @Inject private var paymentService: hPaymentClient

    @Published public internal(set) var paymentData: PaymentData?
    @Published public internal(set) var ongoingPaymentData: [PaymentData] = []
    @Published public internal(set) var paymentStatusData: PaymentStatusData?
    @Published public internal(set) var paymentHistory: [PaymentHistoryListData] = []
    @Published public internal(set) var missedPaymentData: MissedPaymentData?

    @Transient @Published public private(set) var isLoadingPaymentData: Bool = false
    @Transient @Published public private(set) var isFetchingPaymentStatus: Bool = false
    @Transient @Published public private(set) var isLoadingHistory: Bool = false
    @Transient @Published public private(set) var isLoadingMissedPayment: Bool = false

    @Transient @Published public private(set) var loadPaymentDataError: String?
    @Transient @Published public private(set) var fetchPaymentStatusError: String?
    @Transient @Published public private(set) var loadHistoryError: String?
    @Transient @Published public private(set) var loadMissedPaymentError: String?

    public init() {}

    public func load() async {
        isLoadingPaymentData = true
        do {
            let payment = try await paymentService.getPaymentData()
            paymentData = payment.upcoming
            ongoingPaymentData = payment.ongoing
            loadPaymentDataError = nil
        } catch {
            loadPaymentDataError = L10n.General.errorBody
        }
        isLoadingPaymentData = false
    }

    public func fetchPaymentStatus() async {
        isFetchingPaymentStatus = true
        do {
            paymentStatusData = try await paymentService.getPaymentStatusData()
            fetchPaymentStatusError = nil
        } catch {
            fetchPaymentStatusError = L10n.General.errorBody
        }
        isFetchingPaymentStatus = false
    }

    public func getHistory() async {
        isLoadingHistory = true
        do {
            paymentHistory = try await paymentService.getPaymentHistoryData()
            loadHistoryError = nil
        } catch {
            loadHistoryError = L10n.General.errorBody
        }
        isLoadingHistory = false
    }

    public func getMissedPayment() async {
        isLoadingMissedPayment = true
        do {
            missedPaymentData = try await paymentService.getMissedPaymentData()
            loadMissedPaymentError = nil
        } catch {
            missedPaymentData = nil
            loadMissedPaymentError = L10n.General.errorBody
        }
        isLoadingMissedPayment = false
    }

    public func setMissedPaymentData(_ data: MissedPaymentData?) {
        missedPaymentData = data
    }
}
