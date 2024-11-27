import Foundation

public struct HomeContract: Codable, Equatable, Identifiable, Sendable {
    public var id: String?
    var upcomingRenewal: UpcomingRenewal?
    var displayName: String

    public init(
        upcomingRenewal: UpcomingRenewal?,
        displayName: String
    ) {
        self.upcomingRenewal = upcomingRenewal
        self.displayName = displayName
    }
}
