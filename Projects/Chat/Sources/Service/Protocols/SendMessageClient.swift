import Foundation
import hCore

public protocol SendMessageClient {
    func send(message: Message, topic: ChatTopicType?) async throws -> SentMessageWrapper
}
