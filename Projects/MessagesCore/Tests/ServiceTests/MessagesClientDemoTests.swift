import Foundation
import TestDependencies
import Testing

@testable import MessagesCore

@MainActor
final class MessagesClientDemoTests {
    @Test
    func getMessagesReturnsStoredMessagesSuccess() async {
        await recordingErrors {
            let original = [MockData.message(id: "1"), MockData.message(id: "2", body: "body 2")]
            let client = MessagesClientDemo(messages: original)

            let fetched = try await client.getMessages()

            #expect(fetched == original)
        }
    }

    @Test
    func getMessageContentKnownIdSuccess() async {
        await recordingErrors {
            let client = MessagesClientDemo(
                messages: [
                    MockData.message(id: "1", body: "body 1"),
                    MockData.message(id: "2", body: "body 2"),
                ]
            )

            let body = try await client.getMessageContent(messageId: "2").body

            #expect(body == "body 2")
        }
    }

    @Test
    func getMessageContentUnknownIdError() async {
        let client = MessagesClientDemo(messages: [MockData.message(id: "1", body: "body 1")])

        await #expect(throws: MessagesError.self) {
            _ = try await client.getMessageContent(messageId: "missing")
        }
    }

    @Test
    func getMessageContentMessageWithoutBodyError() async {
        let client = MessagesClientDemo(messages: [MockData.message(id: "1", body: nil)])

        await #expect(throws: MessagesError.self) {
            _ = try await client.getMessageContent(messageId: "1")
        }
    }

    @Test
    func sampleMessagesHaveUniqueIdsAndBodiesSuccess() async {
        await recordingErrors {
            let messages = MessagesClientDemo.sampleMessages()

            #expect(!messages.isEmpty)
            #expect(Set(messages.map(\.id)).count == messages.count)
            #expect(messages.allSatisfy { $0.body != nil }, "the demo inbox must be able to open every message")

            let client = MessagesClientDemo(messages: messages)
            for message in messages {
                let body = try await client.getMessageContent(messageId: message.id).body
                #expect(body == message.body)
            }
        }
    }
}
