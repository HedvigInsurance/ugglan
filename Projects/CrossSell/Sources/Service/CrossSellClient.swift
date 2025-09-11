import Addons

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell() async throws -> [CrossSell]
    func getCrossSell(source: CrossSellSource) async throws -> CrossSells
    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel?
}

public enum CrossSellSource: String, Codable, Equatable, Sendable {
    case home
    case closedClaim
    case changeTier
    case addon
    case movingFlow
}
