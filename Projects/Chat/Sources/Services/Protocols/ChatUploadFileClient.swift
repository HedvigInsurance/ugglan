import Foundation
import hCore

public protocol ChatFileUploaderClient {
    func upload(
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel]
}

public struct ChatUploadFileResponseModel: Decodable {
    let uploadToken: String
}

class ChatDemoClients: FetchMessagesClient, SendMessageClient {
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
            nextUntil: nil,
            banner: nil
        )
    }

    func send(message: Message) async throws -> SentMessageWrapper {
        self.messages.append(message)
        return .init(message: message, status: nil)
    }

}
