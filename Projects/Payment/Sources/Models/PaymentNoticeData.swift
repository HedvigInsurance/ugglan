import Foundation

public struct PaymentNoticeData: Codable, Equatable, Sendable, Hashable {
    public let memberId: String
    public let preChargeNoticeId: String?
    public let retryChargeNoticeId: String?

    public init(
        memberId: String,
        preChargeNoticeId: String?,
        retryChargeNoticeId: String?
    ) {
        self.memberId = memberId
        self.preChargeNoticeId = preChargeNoticeId
        self.retryChargeNoticeId = retryChargeNoticeId
    }

    public var hasRetryChargeNotice: Bool {
        retryChargeNoticeId != nil
    }
}

struct PaymentNoticeBadgeTracker {
    private let storageKey = "PaymentNoticeBadgeTracker.seenNotices"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Whether the Payments tab should be badged for `notice`.
    /// When there is nothing new, `notice` is stored as seen so a notice that is cleared and later
    /// comes back is badged again.
    func shouldShowBadge(for notice: PaymentNoticeData) -> Bool {
        let showBadge = hasNewNotice(notice)
        if !showBadge {
            markSeen(notice)
        }
        return showBadge
    }

    func markSeen(_ notice: PaymentNoticeData) {
        var notices = seenNotices()
        notices[notice.memberId] = notice
        saveSeenNotices(notices)
    }

    private func hasNewNotice(_ notice: PaymentNoticeData) -> Bool {
        guard let seenNotice = seenNotices()[notice.memberId] else {
            return notice.preChargeNoticeId != nil || notice.retryChargeNoticeId != nil
        }
        return isNewNoticeId(notice.preChargeNoticeId, comparedTo: seenNotice.preChargeNoticeId)
            || isNewNoticeId(notice.retryChargeNoticeId, comparedTo: seenNotice.retryChargeNoticeId)
    }

    private func isNewNoticeId(_ noticeId: String?, comparedTo seenNoticeId: String?) -> Bool {
        guard let noticeId else { return false }
        return noticeId != seenNoticeId
    }

    private func seenNotices() -> [String: PaymentNoticeData] {
        guard let data = userDefaults.data(forKey: storageKey),
            let notices = try? JSONDecoder().decode([String: PaymentNoticeData].self, from: data)
        else {
            return [:]
        }
        return notices
    }

    private func saveSeenNotices(_ notices: [String: PaymentNoticeData]) {
        guard let encoded = try? JSONEncoder().encode(notices) else { return }
        userDefaults.set(encoded, forKey: storageKey)
    }
}
