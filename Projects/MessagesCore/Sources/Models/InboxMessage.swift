import Foundation

public enum MessageChannel: String, CaseIterable, Codable, Hashable, Sendable {
    case email
    case sms
    case kivra
}

public struct InboxMessage: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let channel: MessageChannel
    /// Product or topic the message is about, e.g. "Home insurance" or "Claim".
    public let category: String
    public let subject: String
    public let preview: String
    public let receivedAt: Date
    public var isRead: Bool
    public let sender: String
    public let senderAddress: String
    /// Set for emails only.
    public let htmlBody: String?
    /// Set for SMS and Kivra messages.
    public let textBody: String?

    public init(
        id: String,
        channel: MessageChannel,
        category: String,
        subject: String,
        preview: String,
        receivedAt: Date,
        isRead: Bool,
        sender: String,
        senderAddress: String,
        htmlBody: String?,
        textBody: String?
    ) {
        self.id = id
        self.channel = channel
        self.category = category
        self.subject = subject
        self.preview = preview
        self.receivedAt = receivedAt
        self.isRead = isRead
        self.sender = sender
        self.senderAddress = senderAddress
        self.htmlBody = htmlBody
        self.textBody = textBody
    }
}

public enum InboxFilter: Hashable, Sendable {
    case all
    case channel(MessageChannel)

    public static let allCases: [InboxFilter] = [.all] + MessageChannel.allCases.map { .channel($0) }

    func includes(_ message: InboxMessage) -> Bool {
        switch self {
        case .all: true
        case let .channel(channel): message.channel == channel
        }
    }
}

public enum InboxSort: Hashable, CaseIterable, Sendable {
    case newestFirst
    case oldestFirst
}

/// Received-date filter. Either end may be open; both ends include their whole day.
public struct InboxDateRange: Hashable, Sendable {
    public let from: Date?
    public let to: Date?

    public init(from: Date?, to: Date?) {
        self.from = from
        self.to = to
    }

    public var isEmpty: Bool { from == nil && to == nil }

    func includes(_ date: Date, calendar: Calendar = .current) -> Bool {
        if let from, date < calendar.startOfDay(for: from) {
            return false
        }
        if let to,
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to)),
            date >= endOfDay
        {
            return false
        }
        return true
    }
}

/// The inbox split into the "Unread" and "Earlier" sections, each filtered and sorted.
public struct InboxSections: Equatable, Sendable {
    public let unread: [InboxMessage]
    public let earlier: [InboxMessage]

    public var isEmpty: Bool { unread.isEmpty && earlier.isEmpty }

    public init(
        messages: [InboxMessage],
        filter: InboxFilter,
        sort: InboxSort,
        dateRange: InboxDateRange? = nil
    ) {
        let sorted = messages
            .filter(filter.includes)
            .filter { dateRange?.includes($0.receivedAt) ?? true }
            .sorted { lhs, rhs in
                switch sort {
                case .newestFirst: lhs.receivedAt > rhs.receivedAt
                case .oldestFirst: lhs.receivedAt < rhs.receivedAt
                }
            }
        unread = sorted.filter { !$0.isRead }
        earlier = sorted.filter(\.isRead)
    }
}
