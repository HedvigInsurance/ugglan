import Foundation
import hCore
import hGraphQL

public protocol hFetchClaimService {
    func get() async throws -> [ClaimModel]
}

class FetchClaimServiceDemo: hFetchClaimService {
    func get() async throws -> [ClaimModel] {
        return []
    }
}

public class FetchClaimServiceOctopus: hFetchClaimService {
    @Inject var octopus: hOctopus

    public init() {}
    public func get() async throws -> [ClaimModel] {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.ClaimsQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        let claimData = data.currentMember.claims.map { ClaimModel(claim: $0) }
        return claimData
    }
}
