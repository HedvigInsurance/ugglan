import Foundation
import hCore

@testable import Home

typealias FetchPuppyGuide = () async throws -> PuppyGuide
typealias SetPuppyGuideStoryRead = (String) async throws -> Void
typealias SetPuppyGuideStoryRating = (String, Int) async throws -> Void

extension MockData {
    @discardableResult
    static func createMockPuppyGuideClient(
        fetchPuppyGuide: @escaping FetchPuppyGuide = { .mock() },
        setStoryRead: @escaping SetPuppyGuideStoryRead = { _ in },
        setStoryRating: @escaping SetPuppyGuideStoryRating = { _, _ in }
    ) -> MockPuppyGuideClient {
        let client = MockPuppyGuideClient(
            fetchPuppyGuide: fetchPuppyGuide,
            setStoryRead: setStoryRead,
            setStoryRating: setStoryRating
        )
        Dependencies.shared.add(module: Module { () -> PuppyGuideClient in client })
        return client
    }
}

class MockPuppyGuideClient: PuppyGuideClient {
    var events = [Event]()
    var fetchPuppyGuide: FetchPuppyGuide
    var setStoryRead: SetPuppyGuideStoryRead
    var setStoryRating: SetPuppyGuideStoryRating

    enum Event: Equatable {
        case getPuppyGuide
        case setStoryRead(name: String)
        case setStoryRating(name: String, rating: Int)
    }

    init(
        fetchPuppyGuide: @escaping FetchPuppyGuide,
        setStoryRead: @escaping SetPuppyGuideStoryRead,
        setStoryRating: @escaping SetPuppyGuideStoryRating
    ) {
        self.fetchPuppyGuide = fetchPuppyGuide
        self.setStoryRead = setStoryRead
        self.setStoryRating = setStoryRating
    }

    func getPuppyGuide() async throws -> PuppyGuide {
        events.append(.getPuppyGuide)
        return try await fetchPuppyGuide()
    }

    func setStoryRead(name: String) async throws {
        events.append(.setStoryRead(name: name))
        try await setStoryRead(name)
    }

    func setStoryRating(name: String, rating: Int) async throws {
        events.append(.setStoryRating(name: name, rating: rating))
        try await setStoryRating(name, rating)
    }
}

extension PuppyGuide {
    static func mock(
        stories: [PuppyGuideStory] = [
            .mock(name: "feeding", categories: ["Food", "Health"]),
            .mock(name: "walking", categories: ["Training"]),
        ],
        isForYoungDog: Bool? = true
    ) -> PuppyGuide {
        PuppyGuide(stories: stories, isForYoungDog: isForYoungDog)
    }
}

extension PuppyGuideStory {
    static func mock(
        name: String,
        categories: [String] = [],
        rating: Int? = nil,
        isRead: Bool = false
    ) -> PuppyGuideStory {
        PuppyGuideStory(
            name: name,
            title: "Title \(name)",
            subtitle: "Subtitle \(name)",
            content: "Content \(name)",
            imageUrl: nil,
            categories: categories,
            rating: rating,
            isRead: isRead
        )
    }
}
