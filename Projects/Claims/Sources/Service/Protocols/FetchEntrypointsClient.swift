import Foundation

@MainActor
public protocol hFetchEntrypointsClient {
    func get() async throws -> [ClaimEntryPointGroupResponseModel]
}
