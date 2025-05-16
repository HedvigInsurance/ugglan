import Chat
import hCore
import hGraphQL

public class EmailMessagesClientOctopus: EmailMessagesClient {
    @Inject private var octopus: hOctopus
    public init() {}
    public func getEmailMessages() async throws -> [EmailMessage] {
        let query = hGraphQL.OctopusGraphQL.EmailMessagesQuery()
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return data.currentMember.emailMessages.compactMap { it in
            EmailMessage(
                id: it.id,
                recipient: it.recipient,
                subject: it.subject,
                body: it.body,
                deliveryType: it.deliveryType,
                createdAt: it.createdAt?.localDateToIso8601Date,
                category: it.category
            )
        }
    }
}
