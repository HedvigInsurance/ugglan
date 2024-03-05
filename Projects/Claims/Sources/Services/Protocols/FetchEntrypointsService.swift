import Foundation

public protocol hFetchEntrypointsService {
    func get() async throws -> [ClaimEntryPointGroupResponseModel]
}
