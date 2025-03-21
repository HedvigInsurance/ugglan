import Addons

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell() async throws -> [CrossSell]
    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel?
}
