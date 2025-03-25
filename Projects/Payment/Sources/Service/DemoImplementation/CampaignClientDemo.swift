public class hCampaignClientDemo: hCampaignClient {
    public init() {}

    public func remove(codeId: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    public func add(code: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
