import Foundation

public class FetchEntrypointsClientDemo: hFetchEntrypointsClient {
    public init() {}
    public func get() async throws -> [ClaimEntryPointGroupResponseModel] {
        [
            ClaimEntryPointGroupResponseModel(
                id: "entrypointId",
                displayName: "EntrypointGroup",
                entrypoints: []
            )
        ]
    }
}
