import AppStateContainer
import Combine
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
    @Published public internal(set) var showsRetryChargeNotice: Bool = false
    @Published public internal(set) var showsPaymentBadge: Bool = false
    @Published public internal(set) var paymentHistory: [PaymentHistoryListData] = []
    @Published public internal(set) var missedPaymentData: MissedPaymentData?
    private var paymentNoticeData: PaymentNoticeData?

    @Transient public internal(set) var paymentNoticeDataFetchedAt: Date?
    @Transient public internal(set) var missedPaymentDataFetchedAt: Date?

    @Transient @Published public private(set) var isLoadingPaymentData: Bool = false
    @Transient @Published public private(set) var isFetchingPaymentStatus: Bool = false
    @Transient @Published public private(set) var isLoadingHistory: Bool = false
    @Transient @Published public private(set) var isLoadingMissedPayment: Bool = false

    @Transient @Published public private(set) var loadPaymentDataError: String?
    @Transient @Published public private(set) var fetchPaymentStatusError: String?
    @Transient @Published public private(set) var loadHistoryError: String?
    @Transient @Published public private(set) var loadMissedPaymentError: String?

    @Transient private var cancellables = Set<AnyCancellable>()

    public init() {
        NotificationCenter.default
            .publisher(for: .didChargeOutstandingPayment)
            .sink { [weak self] _ in
                self?.missedPaymentData = nil
                self?.missedPaymentDataFetchedAt = nil
            }
            .store(in: &cancellables)
    }

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

    var showsPayoutSection: Bool {
        paymentStatusData?.hasAnyPayoutMethod ?? false
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
    private static let paymentNoticeDataCacheDuration: TimeInterval = 15 * 60
    private static let missedPaymentDataCacheDuration: TimeInterval = 30 * 60

    private static func isStale(_ fetchedAt: Date?, after duration: TimeInterval) -> Bool {
        fetchedAt.map { -$0.timeIntervalSinceNow > duration } ?? true
    }

    /// Everything the payments screen renders, fetched concurrently.
    func fetchAllPaymentData(forceUpdate: Bool = false) async {
        async let load: () = load(forceUpdate: forceUpdate)
        async let noticeData: () = fetchPaymentNoticeData(forceUpdate: forceUpdate)
        async let status: () = fetchPaymentStatus()
        async let missedPayment: () = getMissedPayment(forceUpdate: forceUpdate)
        _ = await (load, noticeData, status, missedPayment)
    }

    public func load(forceUpdate: Bool = false) async {
        let isStale = Self.isStale(paymentDataFetchedAt, after: Self.paymentDataCacheDuration)
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

    public func resetPaymentDataFetchedAt() {
        paymentDataFetchedAt = nil
    }

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

    public func fetchPaymentNoticeData(forceUpdate: Bool = false) async {
        let isStale = Self.isStale(paymentNoticeDataFetchedAt, after: Self.paymentNoticeDataCacheDuration)
        guard forceUpdate || isStale else { return }
        do {
            let noticeData = try await paymentService.getPaymentNoticeData()
            updatePaymentNotice(with: noticeData)
            paymentNoticeDataFetchedAt = Date()
        } catch {
            // Notices only drive the tab badge — keep the last known value and stay silent.
        }
    }

    private func updatePaymentNotice(with noticeData: PaymentNoticeData) {
        paymentNoticeData = noticeData
        showsPaymentBadge = PaymentNoticeBadgeTracker().shouldShowBadge(for: noticeData)
        showsRetryChargeNotice = noticeData.hasRetryChargeNotice
    }

    /// Clears the Payments tab badge until a different notice arrives.
    public func markPaymentNoticeSeen() {
        guard showsPaymentBadge else { return }
        if let paymentNoticeData {
            PaymentNoticeBadgeTracker().markSeen(paymentNoticeData)
        }
        showsPaymentBadge = false
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

    public func getMissedPayment(forceUpdate: Bool = false) async {
        let isStale = Self.isStale(missedPaymentDataFetchedAt, after: Self.missedPaymentDataCacheDuration)
        guard forceUpdate || (!isLoadingMissedPayment && isStale) else { return }
        isLoadingMissedPayment = true
        do {
            missedPaymentData = try await paymentService.getMissedPaymentData()
            missedPaymentDataFetchedAt = Date()
            loadMissedPaymentError = nil
        } catch {
            missedPaymentData = nil
            missedPaymentDataFetchedAt = nil
            loadMissedPaymentError = L10n.General.errorBody
        }
        isLoadingMissedPayment = false
    }

    public func setMissedPaymentData(_ data: MissedPaymentData?) {
        missedPaymentData = data
    }
}
