import Foundation

public struct ClaimInProgressModel: Codable, Sendable, Equatable, Hashable {
    let createdAt: Date
    let title: String?

    public init(createdAt: Date, title: String?) {
        self.createdAt = createdAt
        self.title = title
    }
}
