import Foundation
import Testing

@testable import MessagesCore

@MainActor
final class InboxListTests {
    /// `InboxDateRange` compares against `Calendar.current`, so the fixtures are built with it too.
    private static let calendar = Calendar.current

    private static func date(day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        let components = DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute)
        return calendar.date(from: components)!
    }

    private static func message(_ id: String, _ channel: MessageChannel, at date: Date) -> InboxMessage {
        MockData.message(id: id, channel: channel, receivedAt: date)
    }

    private let messages: [InboxMessage] = [
        InboxListTests.message("sms-mid", .sms, at: InboxListTests.date(day: 3, hour: 0)),
        InboxListTests.message("email-old", .email, at: InboxListTests.date(day: 1, hour: 8)),
        InboxListTests.message("sms-new", .sms, at: InboxListTests.date(day: 6, hour: 10)),
        InboxListTests.message("kivra-mid", .kivra, at: InboxListTests.date(day: 3, hour: 23, minute: 59)),
        InboxListTests.message("email-new", .email, at: InboxListTests.date(day: 5)),
    ]

    // MARK: - Sorting

    @Test
    func sortNewestFirstSuccess() {
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst)

        #expect(list.messages.map(\.id) == ["sms-new", "email-new", "kivra-mid", "sms-mid", "email-old"])
        #expect(!list.isEmpty)
    }

    @Test
    func sortOldestFirstSuccess() {
        let list = InboxList(messages: messages, filter: .all, sort: .oldestFirst)

        #expect(list.messages.map(\.id) == ["email-old", "sms-mid", "kivra-mid", "email-new", "sms-new"])
    }

    // MARK: - Channel filter

    @Test(arguments: MessageChannel.allCases)
    func filterByChannelKeepsOnlyThatChannel(channel: MessageChannel) {
        let list = InboxList(messages: messages, filter: .channel(channel), sort: .newestFirst)
        let expected = messages.filter { $0.channel == channel }.sorted { $0.receivedAt > $1.receivedAt }

        #expect(list.messages.allSatisfy { $0.channel == channel })
        #expect(list.messages.map(\.id) == expected.map(\.id))
    }

    @Test
    func filterEmailSortsOldestFirstSuccess() {
        let list = InboxList(messages: messages, filter: .channel(.email), sort: .oldestFirst)

        #expect(list.messages.map(\.id) == ["email-old", "email-new"])
    }

    @Test
    func filterAllKeepsEveryMessage() {
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst)

        #expect(Set(list.messages.map(\.id)) == Set(messages.map(\.id)))
    }

    // MARK: - Date range

    @Test
    func dateRangeIncludesWholeDaysAtBothEnds() {
        // Times of day on the range ends are ignored: from covers all of day 3, to covers all of day 5.
        let range = InboxDateRange(from: Self.date(day: 3, hour: 18), to: Self.date(day: 5, hour: 0))
        let list = InboxList(messages: messages, filter: .all, sort: .oldestFirst, dateRange: range)

        #expect(list.messages.map(\.id) == ["sms-mid", "kivra-mid", "email-new"])
    }

    @Test
    func dateRangeExcludesStartOfNextDay() {
        let messages = [
            Self.message("last-minute", .email, at: Self.date(day: 3, hour: 23, minute: 59)),
            Self.message("next-midnight", .email, at: Self.date(day: 4, hour: 0)),
        ]
        let range = InboxDateRange(from: Self.date(day: 3), to: Self.date(day: 3))
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst, dateRange: range)

        #expect(list.messages.map(\.id) == ["last-minute"])
    }

    @Test
    func dateRangeOpenEndSuccess() {
        let range = InboxDateRange(from: Self.date(day: 5), to: nil)
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst, dateRange: range)

        #expect(list.messages.map(\.id) == ["sms-new", "email-new"])
    }

    @Test
    func dateRangeOpenStartSuccess() {
        let range = InboxDateRange(from: nil, to: Self.date(day: 3))
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst, dateRange: range)

        #expect(list.messages.map(\.id) == ["kivra-mid", "sms-mid", "email-old"])
    }

    @Test
    func dateRangeWithBothEndsOpenKeepsEveryMessage() {
        let range = InboxDateRange(from: nil, to: nil)
        let withRange = InboxList(messages: messages, filter: .all, sort: .newestFirst, dateRange: range)
        let withoutRange = InboxList(messages: messages, filter: .all, sort: .newestFirst)

        #expect(range.isEmpty)
        #expect(withRange == withoutRange)
        #expect(withRange.messages.count == messages.count)
    }

    @Test
    func dateRangeIsEmptyOnlyWhenBothEndsAreOpen() {
        #expect(InboxDateRange(from: nil, to: nil).isEmpty)
        #expect(!InboxDateRange(from: Self.date(day: 1), to: nil).isEmpty)
        #expect(!InboxDateRange(from: nil, to: Self.date(day: 1)).isEmpty)
    }

    @Test
    func channelFilterAndDateRangeCombine() {
        let range = InboxDateRange(from: Self.date(day: 2), to: Self.date(day: 6))
        let list = InboxList(messages: messages, filter: .channel(.sms), sort: .oldestFirst, dateRange: range)

        #expect(list.messages.map(\.id) == ["sms-mid", "sms-new"])
    }

    // MARK: - isEmpty

    @Test
    func isEmptyForNoMessages() {
        #expect(InboxList(messages: [], filter: .all, sort: .newestFirst).isEmpty)
    }

    @Test
    func isEmptyWhenFilterMatchesNothing() {
        let onlyEmails = messages.filter { $0.channel == .email }
        let list = InboxList(messages: onlyEmails, filter: .channel(.kivra), sort: .newestFirst)

        #expect(list.isEmpty)
    }

    @Test
    func isEmptyWhenDateRangeMatchesNothing() {
        let range = InboxDateRange(from: Self.date(day: 20), to: Self.date(day: 25))
        let list = InboxList(messages: messages, filter: .all, sort: .newestFirst, dateRange: range)

        #expect(list.isEmpty)
    }

    // MARK: - InboxFilter

    @Test
    func filterAllCasesListsAllThenEachChannel() {
        #expect(InboxFilter.allCases == [.all, .channel(.email), .channel(.sms), .channel(.kivra)])
    }
}
