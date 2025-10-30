import Foundation

@MainActor
public protocol hFetchClaimsClient {
    func getActiveClaims() async throws -> [ClaimModel]
    func getHistoryClaims() async throws -> [ClaimModel]
}
