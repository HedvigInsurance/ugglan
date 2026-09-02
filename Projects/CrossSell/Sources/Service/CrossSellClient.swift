import Addons

@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell(source: CrossSellSource) async throws -> CrossSells
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner]
}

public enum CrossSellSource: Codable, Equatable, Sendable {
    public typealias RawValue = String

    case homeXSell
    case closedClaim(claimId: String, contractId: String?)
    case changeTier(contractId: String)
    case addon
    case movingFlow(contractId: String)
    case home
    case insurances
    case onboarding

    public var rawValue: RawValue {
        switch self {
        case .homeXSell: "homeXSell"
        case .closedClaim: "closedClaim"
        case .changeTier: "changeTier"
        case .addon: "addon"
        case .movingFlow: "movingFlow"
        case .home: "home"
        case .insurances: "insurances"
        case .onboarding: "onboarding"
        }
    }
}
