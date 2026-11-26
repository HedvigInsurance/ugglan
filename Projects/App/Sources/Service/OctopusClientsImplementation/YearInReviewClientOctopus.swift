import Foundation
import Home
import hCore
import hGraphQL

class YearInReviewClientOctopus: YearInReviewClient {
    @Inject private var octopus: hOctopus

    func getStories() async throws -> [Story] {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.YearInReviewQuery())
        // Articles have no id, so their position is used; the order is fixed by the backend
        return data.currentMember.yearInReview.enumerated()
            .map { index, article in
                Story(
                    id: String(index),
                    title: article.title,
                    description: article.description,
                    fileUrl: article.fileUrl.flatMap { URL(string: $0) },
                    action: article.action.flatMap { action in
                        URL(string: action.url).map { StoryAction(title: action.title, url: $0) }
                    }
                )
            }
    }
}
