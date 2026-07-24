import Addons
import Foundation

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell(source: CrossSellSource, contractId: String?) async throws -> CrossSells
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner]
}

public enum CrossSellSource: Codable, Equatable, Sendable {
    public typealias RawValue = String

    case home
    case closedClaim(claimId: String)
    case changeTier
    case addon
    case movingFlow
    case insurances

    public var rawValue: RawValue {
        switch self {
        case .home: "home"
        case .closedClaim: "closedClaim"
        case .changeTier: "changeTier"
        case .addon: "addon"
        case .movingFlow: "movingFlow"
        case .insurances: "insurances"
        }
    }
}
