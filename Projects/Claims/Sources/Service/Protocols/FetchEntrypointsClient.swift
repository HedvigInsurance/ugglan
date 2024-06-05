import Foundation

public protocol hFetchEntrypointsClient {
    func get() async throws -> [ClaimEntryPointGroupResponseModel]
}
