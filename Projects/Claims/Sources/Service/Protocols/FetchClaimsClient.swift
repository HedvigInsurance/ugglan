import Foundation
import hCore
import hGraphQL

@MainActor
class FetchClaimService {
    @Inject var client: hFetchClaimsClient
    public func get() async throws -> [ClaimModel] {
        log.info("FetchClaimService: get", error: nil, attributes: nil)
        return try await client.get()
    }
}

@MainActor
public protocol hFetchClaimsClient {
    func get() async throws -> [ClaimModel]
}
