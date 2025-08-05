import Foundation
import hCore

@MainActor
class FetchClaimService {
    @Inject var client: hFetchClaimsClient
    func getActiveClaims() async throws -> [ClaimModel] {
        log.info("FetchClaimService: get", error: nil, attributes: nil)
        return try await client.getActiveClaims()
    }

    func getHistoryClaims() async throws -> [ClaimModel] {
        log.info("FetchClaimService: get", error: nil, attributes: nil)
        return try await client.getHistoryClaims()
    }
}

@MainActor
public protocol hFetchClaimsClient {
    func getActiveClaims() async throws -> [ClaimModel]
    func getHistoryClaims() async throws -> [ClaimModel]
}
