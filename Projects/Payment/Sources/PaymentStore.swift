import AppStateContainer
import Foundation
import hCore

@MainActor
@PersistableStore
public final class PaymentStore: AppStore {
    @Inject private var paymentService: hPaymentClient

    @Published public internal(set) var paymentData: PaymentData?
    @Published public internal(set) var paymentDataFetchedAt: Date?
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
        case .other: return paymentStatusData.hasAnyPayoutMethod
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

    /// The single decision about the connect-payment card: `nil` means no card at all. Hosts
    /// render what this returns rather than each re-deriving when a card is warranted — Home
    /// adds only its own member-state gate, which `PaymentStore` cannot see.
    public var connectPaymentPrompt: ConnectPaymentPrompt? {
        guard let paymentStatusData else { return nil }
        if case let .terminatingDueToMissedPayments(date) = paymentStatusData.status {
            return .missedPayments(date: date)
        }
        return showsConnectPayment ? .needsSetup : nil
    }

    var showsConnectPayout: Bool {
        paymentStatusData?.missingConnection == .payout && !showsConnectPayment
    }

    private static let paymentDataCacheDuration: TimeInterval = 30 * 60

    public func load(forceUpdate: Bool = false) async {
        let isStale = paymentDataFetchedAt.map { -$0.timeIntervalSinceNow > Self.paymentDataCacheDuration } ?? true
        guard forceUpdate || (!isLoadingPaymentData && isStale) else { return }
        isLoadingPaymentData = true
        do {
            let payment = try await paymentService.getPaymentData()
            paymentData = payment.upcoming
            ongoingPaymentData = payment.ongoing
            paymentDataFetchedAt = Date()
            loadPaymentDataError = nil
        } catch {
            loadPaymentDataError = L10n.General.errorBody
        }
        isLoadingPaymentData = false
    }

    /// Several screens refresh on appear and every setup completion refreshes detached, so the
    /// same query gets asked for twice within milliseconds. One in flight is enough — matching
    /// `load(forceUpdate:)`, which already guards on its own loading flag.
    public func fetchPaymentStatus() async {
        guard !isFetchingPaymentStatus else { return }
        isFetchingPaymentStatus = true
        do {
            paymentStatusData = try await paymentService.getPaymentStatusData()
            fetchPaymentStatusError = nil
        } catch {
            fetchPaymentStatusError = L10n.General.errorBody
        }
        isFetchingPaymentStatus = false
    }

    /// Detached so a refresh kicked off from a sheet's completion outlives that sheet's teardown.
    static func refreshStatusDetached() {
        Task {
            let store: PaymentStore = globalAppStateContainer.get()
            await store.fetchPaymentStatus()
        }
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
