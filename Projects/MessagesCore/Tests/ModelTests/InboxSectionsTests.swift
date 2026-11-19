import Foundation
import Testing

@testable import MessagesCore

@MainActor
final class InboxSectionsTests {
    private let messages: [InboxMessage] = [
        InboxSectionsTests.message("email-unread-old", .email, at: 100),
        InboxSectionsTests.message("email-read-new", .email, at: 500, isRead: true),
        InboxSectionsTests.message("sms-unread-new", .sms, at: 400),
        InboxSectionsTests.message("sms-read-old", .sms, at: 200, isRead: true),
        InboxSectionsTests.message("kivra-read-mid", .kivra, at: 300, isRead: true),
    ]

    private static func message(
        _ id: String,
        _ channel: MessageChannel,
        at seconds: TimeInterval,
        isRead: Bool = false
    ) -> InboxMessage {
        MockData.message(id: id, channel: channel, receivedAt: .init(timeIntervalSince1970: seconds), isRead: isRead)
    }

    @Test
    func groupsUnreadAndEarlierNewestFirst() {
        let sections = InboxSections(messages: messages, filter: .all, sort: .newestFirst)

        #expect(sections.unread.map(\.id) == ["sms-unread-new", "email-unread-old"])
        #expect(sections.earlier.map(\.id) == ["email-read-new", "kivra-read-mid", "sms-read-old"])
        #expect(!sections.isEmpty)
    }

    @Test
    func groupsUnreadAndEarlierOldestFirst() {
        let sections = InboxSections(messages: messages, filter: .all, sort: .oldestFirst)

        #expect(sections.unread.map(\.id) == ["email-unread-old", "sms-unread-new"])
        #expect(sections.earlier.map(\.id) == ["sms-read-old", "kivra-read-mid", "email-read-new"])
    }

    @Test(arguments: MessageChannel.allCases)
    func filterByChannelKeepsOnlyThatChannel(channel: MessageChannel) {
        let sections = InboxSections(messages: messages, filter: .channel(channel), sort: .newestFirst)
        let all = sections.unread + sections.earlier
        let expectedCount = messages.filter { $0.channel == channel }.count
        let unreadIsUnread = sections.unread.allSatisfy { !$0.isRead }
        let earlierIsRead = sections.earlier.allSatisfy(\.isRead)

        #expect(all.allSatisfy { $0.channel == channel })
        #expect(all.count == expectedCount)
        #expect(unreadIsUnread)
        #expect(earlierIsRead)
    }

    @Test
    func filterEmailGroupsAndSorts() {
        let sections = InboxSections(messages: messages, filter: .channel(.email), sort: .newestFirst)

        #expect(sections.unread.map(\.id) == ["email-unread-old"])
        #expect(sections.earlier.map(\.id) == ["email-read-new"])
    }

    @Test
    func filterSmsGroupsAndSorts() {
        let sections = InboxSections(messages: messages, filter: .channel(.sms), sort: .oldestFirst)

        #expect(sections.unread.map(\.id) == ["sms-unread-new"])
        #expect(sections.earlier.map(\.id) == ["sms-read-old"])
    }

    @Test
    func filterKivraHasNoUnread() {
        let sections = InboxSections(messages: messages, filter: .channel(.kivra), sort: .newestFirst)

        #expect(sections.unread.isEmpty)
        #expect(sections.earlier.map(\.id) == ["kivra-read-mid"])
        #expect(!sections.isEmpty)
    }

    @Test
    func isEmptyForNoMessages() {
        #expect(InboxSections(messages: [], filter: .all, sort: .newestFirst).isEmpty)
    }

    @Test
    func isEmptyWhenFilterMatchesNothing() {
        let onlyEmails = messages.filter { $0.channel == .email }
        let sections = InboxSections(messages: onlyEmails, filter: .channel(.kivra), sort: .newestFirst)

        #expect(sections.isEmpty)
    }

    @Test
    func filterAllCasesListsAllThenEachChannel() {
        #expect(InboxFilter.allCases == [.all, .channel(.email), .channel(.sms), .channel(.kivra)])
    }
}
