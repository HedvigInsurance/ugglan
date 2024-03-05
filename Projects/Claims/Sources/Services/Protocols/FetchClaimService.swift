import Foundation
import hCore

public protocol hFetchClaimService {
    func get() async throws -> [ClaimModel]
    func getFiles() async throws -> [String: [File]]
}
