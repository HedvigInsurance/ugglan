import Addons

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell(source: CrossSellSource) async throws -> CrossSells
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner]
}

public enum CrossSellSource: String, Codable, Equatable, Sendable {
    case home
    case closedClaim
    case changeTier
    case addon
    case movingFlow
    case insurances
}
