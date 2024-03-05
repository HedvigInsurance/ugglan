import Foundation

public class FetchEntrypointsServiceDemo: hFetchEntrypointsService {
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
