import Foundation
import hCore
import hGraphQL

public class FetchMessagesClientOctopus: FetchMessagesClient {
    @Inject var octopus: hOctopus
    public init() {}
    public func get(_ next: String?) async throws -> ChatData {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ChatQuery(until: next),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return .init(with: data.chat)
    }
}

extension OctopusGraphQL.MessageFragment {
    func asMessage() -> Message {
        return .init(
            remoteId: id,
            type: messageType,
            sender: self.sender == .hedvig ? .hedvig : .member,
            date: self.sentAt.localDateToIso8601Date ?? Date()
        )
    }

    private var messageType: MessageType {
        if let text = self.asChatMessageText?.text {
            if let url = URL(string: text), text.isUrl {
                if text.isGIFURL {
                    return .file(file: .init(id: self.id, size: 0, mimeType: .GIF, name: "", source: .url(url: url)))
                } else if text.isCrossSell {
                    return .crossSell(url: url)
                } else if text.isDeepLink {
                    return .deepLink(url: url)
                } else {
                    return .otherLink(url: url)
                }
            } else {
                return .text(text: text)
            }
        } else if let file = self.asChatMessageFile {
            if let url = URL(string: file.signedUrl) {
                let mimeType = MimeType.findBy(mimeType: file.mimeType)
                return .file(file: .init(id: id, size: 0, mimeType: mimeType, name: "", source: .url(url: url)))
            } else {
                return .unknown
            }
        } else {
            return .unknown
        }
    }
}

extension ChatData {
    init(with data: OctopusGraphQL.ChatQuery.Data.Chat) {
        self.id = data.id
        self.hasNext = data.hasNext
        self.nextUntil = data.nextUntil
        self.messages = data.messages.compactMap({ $0.fragments.messageFragment.asMessage() })
        self.banner = data.bannerText
    }
}
