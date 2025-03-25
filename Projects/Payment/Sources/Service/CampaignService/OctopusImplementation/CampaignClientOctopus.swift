import hCore

@MainActor
public class hCampaignService {
    @Inject var service: hCampaignClient

    public func remove(codeId: String) async throws {
        log.info("hCampaignService: remove", error: nil, attributes: nil)
        return try await service.remove(codeId: codeId)
    }

    public func add(code: String) async throws {
        log.info("hCampaignService: add", error: nil, attributes: nil)
        return try await service.add(code: code)
    }
}
