import Foundation

@MainActor
public protocol PuppyGuideClient {
    func getPuppyGuide() async throws -> PuppyGuide?
    func setStoryRead(name: String) async throws
    func setStoryRating(name: String, rating: Int) async throws
}

public enum PuppyGuideError: Error {
    case engagementNotSaved
}
