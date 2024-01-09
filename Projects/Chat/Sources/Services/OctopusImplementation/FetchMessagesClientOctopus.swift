import Foundation
import hCore
import hGraphQL

public class FetchMessagesClientOctopus: FetchMessagesClient {
    @Inject var octopus: hOctopus

    public func get() async throws -> ChatData {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ChatQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return .init(with: data.chat)
    }

    public func get(for next: String?) async throws -> ChatData {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ChatQuery(until: next),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return .init(with: data.chat)
    }
}

extension OctopusGraphQL.MessageFragment {
    func asMessage() -> Message {
        return .init()
    }
}

extension ChatData {
    init(with data: OctopusGraphQL.ChatQuery.Data.Chat) {
        self.id = data.id
        self.hasNext = data.hasNext
        self.nextUntil = data.nextUntil
        self.messages = data.messages.compactMap({ $0.fragments.messageFragment.asMessage() })
    }
}
