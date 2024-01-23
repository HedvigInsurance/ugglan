import Foundation
import hCore

public class ChatDemoClient: FetchMessagesClient, SendMessageClient {
    var messages = [Message]()

    public init() {
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
            .init(
                remoteId: UUID().uuidString,
                type: .file(
                    file:
                        .init(
                            id: UUID().uuidString,
                            size: 0,
                            mimeType: .GIF,
                            name: "",
                            source: .url(
                                url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!
                            )
                        )
                ),
                sender: .member,
                date: Date()
            ),
            .init(
                remoteId: UUID().uuidString,
                type: .file(
                    file:
                        .init(
                            id: UUID().uuidString,
                            size: 0,
                            mimeType: .other(type: ""),
                            name: "",
                            source: .url(
                                url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!
                            )
                        )
                ),
                sender: .member,
                date: Date()
            ),
        ]
    }

    public func get(_ next: String?) async throws -> ChatData {
        return .init(
            hasNext: true,
            id: UUID().uuidString,
            messages: messages,
            nextUntil: nil,
            informationMessage: """
                Information message with deeplink asd asd as *[Help Center](https://hedvigtest.page.link/help-center)*
                """
        )
    }

    public func send(message: Message) async throws -> SentMessageWrapper {
        self.messages.append(message)
        return .init(message: message, status: nil)
    }
}
