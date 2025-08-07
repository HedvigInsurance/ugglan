import Claims
import Foundation
import hCore
import hGraphQL

class FetchClaimDetailsClientOctopus: hFetchClaimDetailsClient {
    @Inject var octopus: hOctopus

    func get(for type: FetchClaimDetailsType) async throws -> ClaimModel {
        switch type {
        case let .claim(id, claimStatus):
            switch claimStatus {
            case .active:
                if Dependencies.featureFlags().isClaimHistoryEnabled {
                    let query = OctopusGraphQL.ActiveClaimsQuery()
                    let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                    if let claimFragment = data.currentMember.claimsActive.first(where: { $0.id == id })?.fragments
                        .claimFragment
                    {
                        return ClaimModel(claim: claimFragment)
                    }
                    throw FetchClaimDetailsError.noClaimFound
                } else {
                    let query = OctopusGraphQL.ClaimsQuery()
                    let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                    if let claimFragment = data.currentMember.claims.first(where: { $0.id == id })?.fragments
                        .claimFragment
                    {
                        return ClaimModel(claim: claimFragment)
                    }
                    throw FetchClaimDetailsError.noClaimFound
                }
            case .history:
                let query = OctopusGraphQL.HistoryClaimsQuery()
                let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
                if let claimFragment = data.currentMember.claimsHistory.first(where: { $0.id == id })?.fragments
                    .claimFragment
                {
                    return ClaimModel(claim: claimFragment)
                }
                throw FetchClaimDetailsError.noClaimFound
            }
        case let .conversation(id):
            let query = OctopusGraphQL.ClaimFromConversationQuery(conversationId: id)
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            if let claimFragment = data.conversation?.claim?.fragments.claimFragment {
                return ClaimModel(claim: claimFragment)
            }
            throw FetchClaimDetailsError.noClaimFound
        }
    }

    func getFiles(for type: FetchClaimDetailsType) async throws -> (claimId: String, files: [File]) {
        switch type {
        case let .claim(id, claimStatus):
            switch claimStatus {
            case .active:
                if Dependencies.featureFlags().isClaimHistoryEnabled {
                    let query = OctopusGraphQL.ActiveClaimsFilesQuery()
                    let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

                    if let files = data.currentMember.claimsActive.first(where: { $0.id == id })?.files
                        .compactMap({ File(with: $0.fragments.fileFragment) })
                    {
                        return (id, files)
                    }
                } else {
                    let query = OctopusGraphQL.ClaimsFilesQuery()
                    let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

                    if let files = data.currentMember.claims.first(where: { $0.id == id })?.files
                        .compactMap({ File(with: $0.fragments.fileFragment) })
                    {
                        return (id, files)
                    }
                }
            case .history:
                let query = OctopusGraphQL.HistoryClaimsFilesQuery()
                let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

                if let files = data.currentMember.claimsHistory.first(where: { $0.id == id })?.files
                    .compactMap({ File(with: $0.fragments.fileFragment) })
                {
                    return (id, files)
                }
            }

            throw FetchClaimDetailsError.noClaimFound
        case let .conversation(id):
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

    func acknowledgeClosedStatus(claimId: String) async throws {
        let mutation = OctopusGraphQL.ClaimAcknowledgeClosedStatusMutation(claimAcknowledgeClosedStatusId: claimId)
        let data = try await octopus.client.perform(mutation: mutation)
        if let userError = data.claimAcknowledgeClosedStatus?.userError {
            throw FetchClaimDetailsError.serviceError(message: userError.message ?? L10n.General.errorBody)
        }
    }
}
