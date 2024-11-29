import Foundation
import hCore

@MainActor
public protocol hFetchClaimsClient {
    func get() async throws -> [ClaimModel]
}
