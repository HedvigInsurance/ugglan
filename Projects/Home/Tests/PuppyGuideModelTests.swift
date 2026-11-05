import Foundation
import Testing

@testable import Home

// Pure value tests: no shared state, so this suite stays top level and runs in parallel.
struct PuppyGuideModelTests {
    @Test
    func entryPlacementWithoutStoriesIsNil() {
        #expect(PuppyGuide.mock(stories: [], isForYoungDog: true).entryPlacement == nil)
        #expect(PuppyGuide.mock(stories: [], isForYoungDog: false).entryPlacement == nil)
        #expect(PuppyGuide.mock(stories: [], isForYoungDog: nil).entryPlacement == nil)
    }

    @Test
    func entryPlacementForYoungDogIsFullCard() {
        #expect(PuppyGuide.mock(isForYoungDog: true).entryPlacement == .fullCard)
    }

    @Test
    func entryPlacementForOlderDogIsQuickAction() {
        #expect(PuppyGuide.mock(isForYoungDog: false).entryPlacement == .quickAction)
    }

    @Test
    func entryPlacementWithUnknownDogAgeIsQuickAction() {
        #expect(PuppyGuide.mock(isForYoungDog: nil).entryPlacement == .quickAction)
    }

    @Test
    func categoriesAreUniqueInFirstAppearanceOrder() {
        let guide = PuppyGuide.mock(stories: [
            .mock(name: "a", categories: ["Health", "Food"]),
            .mock(name: "b", categories: ["Training", "Health"]),
            .mock(name: "c", categories: []),
            .mock(name: "d", categories: ["Food", "Play"]),
        ])

        #expect(guide.categories == ["Health", "Food", "Training", "Play"])
    }

    @Test
    func categoriesWithoutStoriesIsEmpty() {
        #expect(PuppyGuide.mock(stories: []).categories.isEmpty)
    }

    @Test
    func storiesInCategoryReturnsMatchingStoriesInOrder() {
        let guide = PuppyGuide.mock(stories: [
            .mock(name: "a", categories: ["Health", "Food"]),
            .mock(name: "b", categories: ["Training"]),
            .mock(name: "c", categories: ["Food"]),
        ])

        #expect(guide.stories(in: "Food").map(\.name) == ["a", "c"])
        #expect(guide.stories(in: "Training").map(\.name) == ["b"])
        #expect(guide.stories(in: "Unknown").isEmpty)
    }

    @Test
    func showsAsReadWhenReadOrRated() {
        #expect(PuppyGuideStory.mock(name: "a", rating: nil, isRead: false).showsAsRead == false)
        #expect(PuppyGuideStory.mock(name: "a", rating: nil, isRead: true).showsAsRead)
        #expect(PuppyGuideStory.mock(name: "a", rating: 3, isRead: false).showsAsRead)
        #expect(PuppyGuideStory.mock(name: "a", rating: 3, isRead: true).showsAsRead)
    }
}
