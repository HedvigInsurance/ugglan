import Foundation
import hCore

public protocol SendMessageClient {
    func send(message: Message) async throws -> SentMessageWrapper
}
