import Foundation
import hCore

public protocol SendMessageClient {
    func send(message: String) async throws -> SentMessageWrapper
    func send(for file: File) async throws -> SentMessageWrapper
}
