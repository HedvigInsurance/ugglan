import Foundation
import hCore

@MainActor
class FetchEntrypointsService {
    @Inject private var client: hFetchEntrypointsClient

    init() {}

    func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        let data = try await client.get()
        log.info("\(FetchEntrypointsService.self): get ", error: nil, attributes: ["data": data])
        return data
    }
}

@MainActor
public protocol hFetchEntrypointsClient {
    func get() async throws -> [ClaimEntryPointGroupResponseModel]
}
