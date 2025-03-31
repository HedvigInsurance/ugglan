import Addons
import hCore

@MainActor
class CrossSellService {
    @Inject var service: CrossSellClient

    func getCrossSell() async throws -> [CrossSell] {
        log.info("CrossSellService: getCrossSell", error: nil, attributes: nil)
        return try await service.getCrossSell()
    }

    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        log.info("CrossSellService: getAddonBannerModel", error: nil, attributes: nil)
        return try await service.getAddonBannerModel(source: source)
    }

}
