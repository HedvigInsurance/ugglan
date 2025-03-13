import hCore

@MainActor
public class CrossSellService {
    @Inject var service: CrossSellClient

    public func getCrossSell() async throws -> [CrossSell] {
        log.info("CrossSellService: getCrossSell", error: nil, attributes: nil)
        return try await service.getCrossSell()
    }
}
