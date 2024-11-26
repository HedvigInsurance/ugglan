import Foundation
import hCore

@MainActor
public protocol hFetchClaimClient {
    func get() async throws -> [ClaimModel]
    func getFiles() async throws -> [String: [File]]
}
