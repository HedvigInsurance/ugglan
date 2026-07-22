import Foundation

public struct ClaimInProgressModel: Codable, Sendable, Equatable, Hashable {
    let id: String
    let createdAt: Date
    let title: String

    public init(id: String, createdAt: Date, title: String) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
    }

    var isExpired: Bool {
        guard let expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: createdAt) else {
            return false
        }
        return Date() > expiryDate
    }
}
