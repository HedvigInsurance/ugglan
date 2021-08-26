import Apollo
import Flow
import Foundation

struct GraphQLError: Error { var errors: [Error] }

extension ApolloClient {
	public func fetchEmbarkStory(name: String, locale: String) -> Future<hEmbarkStory> {
		Future<hEmbarkStory> { completion in
			let cancellable = self.fetch(
				query:
					GraphQL.EmbarkStoryQuery(
						name: name,
						locale: locale
					),
				cachePolicy: .returnCacheDataElseFetch,
				contextIdentifier: nil,
				queue: .main
			) { result in
				switch result {
				case let .success(result):
					if let story = result.data?.embarkStory {
						completion(.success(hEmbarkStory(story: story)))
					} else if let errors = result.errors {
						completion(.failure(GraphQLError(errors: errors)))
					} else {
						fatalError("Invalid GraphQL state")
					}
				case let .failure(error):
					print(error)
				}
			}

			return Disposer { cancellable.cancel() }
		}
	}
}

public struct hEmbarkStory: Codable {
	public let id: String
	public let passages: [hEmbarkPassage]
	public let initialPassage: hEmbarkPassage?

	internal init(
		story: GraphQL.EmbarkStoryQuery.Data.EmbarkStory
	) {
		self.id = story.id
		self.passages = story.passages.map { .init(passage: $0) }
		self.initialPassage = story.passages.first(where: { $0.name == story.startPassage })
			.map { .init(passage: $0) }
	}
}

public struct hEmbarkPassage: Codable {
	public let name: String
	public let redirects: [hEmbarkRedirect]
	public let externalRedirect: hEmbarkExternalRedirect?
    public let action: hEmbarkAction?
	init(
		passage: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
	) {
		name = passage.name
		redirects = passage.redirects.map { .init(redirect: $0) }
		if let location = passage.externalRedirect?.data.location {
			externalRedirect = .init(location: .init(rawValue: location.rawValue))
		} else {
			externalRedirect = nil
		}
        action = hEmbarkAction(action: passage.action)
	}
}

public enum ExternalRedirectLocation: String, Codable {
	case mailingList = "MailingList"
	case offer = "Offer"
	case close = "Close"
	case chat = "Chat"
}

public struct hEmbarkExternalRedirect: Codable {
	public let location: ExternalRedirectLocation?
}
