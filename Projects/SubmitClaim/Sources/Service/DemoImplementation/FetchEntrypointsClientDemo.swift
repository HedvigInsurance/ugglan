import Foundation

public class FetchEntrypointsClientDemo: hFetchEntrypointsClient {
    public init() {}
    public func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        return [
            ClaimEntryPointGroupResponseModel(
                id: "entrypointId",
                displayName: "EntrypointGroup",
                entrypoints: []
            )
        ]
    }
}
