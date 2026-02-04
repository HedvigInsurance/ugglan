import Addons
import hCore

@MainActor
class CrossSellService {
    @Inject var client: CrossSellClient

    func getCrossSell(source: CrossSellSource) async throws -> CrossSells {
        log.info("CrossSellService: getCrossSell", error: nil, attributes: nil)
        return try await client.getCrossSell(source: source)
    }

    func getAddonBanners(source: AddonSource) async throws -> [AddonBannerModel] {
        log.info("CrossSellService: getAddonBanners", error: nil, attributes: nil)
        return try await client.getAddonBanners(source: source)
    }
}
