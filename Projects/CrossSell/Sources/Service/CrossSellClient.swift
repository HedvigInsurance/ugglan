import Addons

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell(source: CrossSellSource) async throws -> CrossSells
    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel?
}

public enum CrossSellSource {
    case home
    case closedClam
    case changeTier
    case addon
    case editCoinsured
    case movingFlow
}
