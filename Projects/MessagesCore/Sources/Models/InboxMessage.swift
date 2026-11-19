import Foundation

public enum MessageChannel: String, CaseIterable, Codable, Hashable, Sendable {
    case email
    case sms
    case kivra
}

public struct InboxMessage: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let channel: MessageChannel
    /// Nil for messages without one, e.g. SMS.
    public let subject: String?
    /// Email preheader. Nil when the message has none or the backend hasn't fetched it yet; filled in on open
    /// by `MessagesStore.loadBody(messageId:)` if the content has one.
    public var preview: String?
    public let receivedAt: Date
    /// The address the message was sent from, when known.
    public let sender: String?
    /// HTML for emails, plain text otherwise. Nil until loaded with `MessagesStore.loadBody(messageId:)`.
    public var body: String?

    public init(
        id: String,
        channel: MessageChannel,
        subject: String?,
        preview: String?,
        receivedAt: Date,
        sender: String?,
        body: String?
    ) {
        self.id = id
        self.channel = channel
        self.subject = subject
        self.preview = preview
        self.receivedAt = receivedAt
        self.sender = sender
        self.body = body
    }
}

public struct InboxMessageContent: Hashable, Sendable {
    public let body: String
    public let preview: String?

    public init(body: String, preview: String?) {
        self.body = body
        self.preview = preview
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

public struct InboxList: Equatable, Sendable {
    public let messages: [InboxMessage]

    public var isEmpty: Bool { messages.isEmpty }

    public init(
        messages: [InboxMessage],
        filter: InboxFilter,
        sort: InboxSort,
        dateRange: InboxDateRange? = nil
    ) {
        self.messages =
            messages
            .filter(filter.includes)
            .filter { dateRange?.includes($0.receivedAt) ?? true }
            .sorted { lhs, rhs in
                switch sort {
                case .newestFirst: lhs.receivedAt > rhs.receivedAt
                case .oldestFirst: lhs.receivedAt < rhs.receivedAt
                }
            }
    }
}
