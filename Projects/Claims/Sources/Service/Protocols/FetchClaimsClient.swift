import Foundation
import hCore

@MainActor
public protocol hFetchClaimsClient {
    func getActiveClaims() async throws -> [ClaimModel]
    func getHistoryClaims() async throws -> [ClaimModel]
}
