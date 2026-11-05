import Foundation

public class PuppyGuideClientDemo: PuppyGuideClient {
    public init() {}

    public func getPuppyGuide() async throws -> PuppyGuide {
        .init(
            stories: [
                .init(
                    name: "puppy-food",
                    title: "Puppy food",
                    subtitle: "5 min read",
                    content: "Choosing the right food is one of the most important things you can do for your puppy.",
                    imageUrl: nil,
                    categories: ["Food"],
                    rating: 5,
                    isRead: true
                ),
                .init(
                    name: "puppy-training",
                    title: "Puppy training",
                    subtitle: "4 min read",
                    content: "Start training early, keep the sessions short and reward good behaviour.",
                    imageUrl: nil,
                    categories: ["Training"],
                    rating: nil,
                    isRead: false
                ),
                .init(
                    name: "first-vet-visit",
                    title: "The first vet visit",
                    subtitle: "3 min read",
                    content: "Book the first visit within a couple of weeks of bringing your puppy home.",
                    imageUrl: nil,
                    categories: ["Health", "Food"],
                    rating: nil,
                    isRead: false
                ),
            ],
            isForYoungDog: true
        )
    }

    public func setStoryRead(name: String) async throws {}

    public func setStoryRating(name: String, rating: Int) async throws {}
}
