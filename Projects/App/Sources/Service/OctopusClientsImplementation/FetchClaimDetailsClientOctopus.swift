import Claims
import Foundation
import hCore
import hGraphQL

public class FetchClaimDetailsClientOctopus: hFetchClaimDetailsClient {
    @Inject var octopus: hOctopus
    public init() {}
    public func get(for type: FetchClaimDetailsType) async throws -> ClaimModel {
        switch type {
        case .claim(let id):
            let query = OctopusGraphQL.ClaimsQuery()
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            if let claimFragment = data.currentMember.claims.first(where: { $0.id == id })?.fragments.claimFragment {
                return ClaimModel(claim: claimFragment)
            }
            throw FetchClaimDetailsError.noClaimFound
        case .conversation(let id):
            let query = OctopusGraphQL.ClaimFromConversationQuery(conversationId: id)
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            if let claimFragment = data.conversation?.claim?.fragments.claimFragment {
                return ClaimModel(claim: claimFragment)
            }
            throw FetchClaimDetailsError.noClaimFound
        }
    }

    public func getFiles(for type: FetchClaimDetailsType) async throws -> (claimId: String, files: [hCore.File]) {
        switch type {
        case .claim(let id):
            let query = OctopusGraphQL.ClaimsFilesQuery()
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

            if let files = data.currentMember.claims.first(where: { $0.id == id })?.files
                .compactMap({ File(with: $0.fragments.fileFragment) })
            {
                return (id, files)
            }
            throw FetchClaimDetailsError.noClaimFound
        case .conversation(let id):
            let query = OctopusGraphQL.ClaimFilesFromConversationQuery(conversationId: id)
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            if let claimId = data.conversation?.claim?.id,
                let files = data.conversation?.claim?.files.compactMap({ File(with: $0.fragments.fileFragment) })
            {
                return (claimId, files)
            }
            throw FetchClaimDetailsError.noClaimFound
        }
    }
}
