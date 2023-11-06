public protocol hCampaignsService {
    func remove(code: String) async throws
    func add(code: String) async throws
}

public class hCampaignsServiceDemo: hCampaignsService {

    public init() {}
    public func remove(code: String) async throws {

    }
    public func add(code: String) async throws {

    }
}
