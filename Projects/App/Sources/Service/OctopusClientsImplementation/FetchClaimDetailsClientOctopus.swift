import Claims
import Foundation
import hCore
import hGraphQL

class FetchClaimDetailsClientOctopus: hFetchClaimDetailsClient {
    @Inject var octopus: hOctopus
    func get(for id: String) async throws -> ClaimModel {
        let query = OctopusGraphQL.ClaimQuery(claimId: id)
        let data = try await octopus.client.fetch(query: query)
        if let claimFragment = data.claim?.fragments
            .claimFragment
        {
            return ClaimModel(claim: claimFragment)
        }
        throw FetchClaimDetailsError.noClaimFound
    }

    func getFiles(for id: String) async throws -> [File] {
        let query = OctopusGraphQL.ClaimFilesQuery(claimId: id)
        let data = try await octopus.client.fetch(query: query)
        if let claim = data.claim {
            return claim.files.compactMap({ File(with: $0.fragments.fileFragment) })
        }
        throw FetchClaimDetailsError.noClaimFound
    }

    func acknowledgeClosedStatus(for id: String) async throws {
        let mutation = OctopusGraphQL.ClaimAcknowledgeClosedStatusMutation(claimAcknowledgeClosedStatusId: id)
        let data = try await octopus.client.mutation(mutation: mutation)
        if let userError = data?.claimAcknowledgeClosedStatus?.userError {
            throw FetchClaimDetailsError.serviceError(message: userError.message ?? L10n.General.errorBody)
        }
    }
}
