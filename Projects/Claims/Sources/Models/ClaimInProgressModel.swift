import Foundation

public struct ClaimInProgressModel: Codable, Sendable, Equatable, Hashable {
    let id: String
    let createdAt: Date
    let title: String?

    public init(id: String, createdAt: Date, title: String?) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
    }
}
