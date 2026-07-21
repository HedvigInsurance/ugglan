import Addons
import AutomaticLog
import hCore

@MainActor
class CrossSellService {
    @Inject var client: CrossSellClient

    @Log(.error)
    func getCrossSell(source: CrossSellSource, contractId: String?) async throws -> CrossSells {
        try await client.getCrossSell(source: source, contractId: contractId)
    }

    @Log(.error)
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        try await client.getAddonBanners(source: source)
    }
}
