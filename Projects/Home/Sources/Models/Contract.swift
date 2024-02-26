import Foundation

public struct Contract: Codable, Equatable {
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
