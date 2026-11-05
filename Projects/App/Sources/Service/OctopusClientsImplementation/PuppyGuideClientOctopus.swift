import Foundation
import Home
import hCore
import hGraphQL

class PuppyGuideClientOctopus: PuppyGuideClient {
    @Inject private var octopus: hOctopus

    func getPuppyGuide() async throws -> PuppyGuide {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.PuppyGuideQuery())
        let puppyGuide = data.currentMember.puppyGuide
        return .init(
            stories: (puppyGuide?.stories ?? [])
                .map { story in
                    .init(
                        name: story.name,
                        title: story.title,
                        subtitle: story.subtitle,
                        content: story.content,
                        imageUrl: URL(string: story.image),
                        categories: story.categories,
                        rating: story.rating,
                        isRead: story.read
                    )
                },
            isForYoungDog: puppyGuide?.forYoungDog
        )
    }

    func setStoryRead(name: String) async throws {
        let mutation = OctopusGraphQL.PuppyGuideEngagementMutation(name: name, rating: nil, read: true)
        try await performEngagement(mutation)
    }

    func setStoryRating(name: String, rating: Int) async throws {
        let mutation = OctopusGraphQL.PuppyGuideEngagementMutation(
            name: name,
            rating: .some(Int32(rating)),
            read: nil
        )
        try await performEngagement(mutation)
    }

    private func performEngagement(_ mutation: OctopusGraphQL.PuppyGuideEngagementMutation) async throws {
        let data = try await octopus.client.mutation(mutation: mutation)
        guard data?.puppyGuideEngagement.success == true else {
            throw PuppyGuideError.engagementNotSaved
        }
    }
}
