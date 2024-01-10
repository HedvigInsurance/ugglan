import Foundation
import hCore

class ChatDemoClient: FetchMessagesClient, SendMessageClient {
    var messages = [Message]()

    init() {
        self.messages = [
            .init(type: .text(text: "Test message")),
            .init(type: .text(text: "Another message")),
            .init(
                remoteId: UUID().uuidString,
                type: .text(text: "message"),
                sender: .hedvig,
                date: Date().addingTimeInterval(-10000)
            ),
            .init(type: .text(text: "Another message 2")),
            .init(
                remoteId: UUID().uuidString,
                type: .file(
                    file:
                        .init(
                            id: UUID().uuidString,
                            size: 0,
                            mimeType: .PNG,
                            name: "",
                            source: .url(
                                url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!
                            )
                        )
                ),
                sender: .hedvig,
                date: Date()
            ),
        ]
    }

    func get(_ next: String?) async throws -> ChatData {
        return .init(
            hasNext: true,
            id: UUID().uuidString,
            messages: messages,
            nextUntil: nil
        )
    }

    func send(message: String) async throws -> SentMessageWrapper {
        let message = Message(type: .text(text: message))
        self.messages.append(message)
        return .init(message: message, status: nil)
    }

    func send(for file: hCore.File) async throws -> SentMessageWrapper {
        let message = Message(type: .file(file: file))
        self.messages.append(message)
        return .init(message: message, status: nil)
    }

}
