import Foundation
import hCore

public protocol FetchMessagesClient {
    func get(_ next: String?) async throws -> ChatData
}
