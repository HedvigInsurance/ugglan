import Foundation

@MainActor
public protocol YearInReviewClient {
    /// The stories shown in the year in review, in the order they are played
    func getStories() async throws -> [Story]
}
