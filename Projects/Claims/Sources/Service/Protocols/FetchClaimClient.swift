import Foundation
import hCore

public protocol hFetchClaimClient {
    func get() async throws -> [ClaimModel]
    func getFiles() async throws -> [String: [File]]
}
