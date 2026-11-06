import Foundation

public struct PuppyGuide: Equatable, Sendable {
    public let stories: [PuppyGuideStory]
    public let isForYoungDog: Bool?

    public init(stories: [PuppyGuideStory], isForYoungDog: Bool?) {
        self.stories = stories
        self.isForYoungDog = isForYoungDog
    }

    var entryPlacement: PuppyGuideEntryPlacement? {
        guard !stories.isEmpty else { return nil }
        return isForYoungDog == true ? .fullCard : .quickAction
    }

    var categories: [String] {
        var seen = Set<String>()
        return stories.flatMap(\.categories).filter { seen.insert($0).inserted }
    }

    func stories(in category: String) -> [PuppyGuideStory] {
        stories.filter { $0.categories.contains(category) }
    }
}

public struct PuppyGuideStory: Hashable, Sendable, Identifiable {
    public let name: String
    public let title: String
    public let subtitle: String
    public let content: String
    public let imageUrl: URL?
    public let categories: [String]
    public internal(set) var rating: Int?
    public internal(set) var isRead: Bool

    public var id: String { name }

    var showsAsRead: Bool { isRead || rating != nil }

    public init(
        name: String,
        title: String,
        subtitle: String,
        content: String,
        imageUrl: URL?,
        categories: [String],
        rating: Int?,
        isRead: Bool
    ) {
        self.name = name
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.imageUrl = imageUrl
        self.categories = categories
        self.rating = rating
        self.isRead = isRead
    }
}

public enum PuppyGuideEntryPlacement: Sendable {
    case fullCard
    case quickAction
}
