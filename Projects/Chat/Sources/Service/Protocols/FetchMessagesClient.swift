import Foundation
import hCore

public protocol FetchMessagesClient {
    func get(_ next: String?) async throws -> MessagesData
}

public struct MessagesData {
    let messages: [Message]
    let banner: Markdown?
    let olderToken: String?
    let hasNext: Bool
    let title: String?
    let createdAt: String?
}
