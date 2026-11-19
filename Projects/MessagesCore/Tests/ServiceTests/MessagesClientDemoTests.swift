import Foundation
import TestDependencies
import Testing

@testable import MessagesCore

@MainActor
final class MessagesClientDemoTests {
    @Test
    func markAsReadPersistsAcrossGetMessagesSuccess() async {
        await recordingErrors {
            let client = MessagesClientDemo(
                messages: [
                    MockData.message(id: "1"),
                    MockData.message(id: "2"),
                ]
            )

            try await client.markAsRead(messageId: "1")
            let messages = try await client.getMessages()

            #expect(messages.first { $0.id == "1" }?.isRead == true)
            #expect(messages.first { $0.id == "2" }?.isRead == false)
        }
    }

    @Test
    func markAsReadUnknownIdLeavesMessagesUnchanged() async {
        await recordingErrors {
            let original = [MockData.message(id: "1")]
            let client = MessagesClientDemo(messages: original)

            try await client.markAsRead(messageId: "missing")

            let fetched = try await client.getMessages()
            #expect(fetched == original)
        }
    }

    @Test
    func sampleMessagesHaveUniqueIdsAndAnUnreadMessage() {
        let messages = MessagesClientDemo.sampleMessages()

        #expect(Set(messages.map(\.id)).count == messages.count)
        #expect(messages.contains { !$0.isRead })
    }
}
