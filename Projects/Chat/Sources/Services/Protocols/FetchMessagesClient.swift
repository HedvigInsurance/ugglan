import Foundation
import hCore

public protocol FetchMessagesClient {
    func get() async throws -> ChatData
    func get(for next: String?) async throws -> ChatData
}
