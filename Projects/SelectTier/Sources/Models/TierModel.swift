import hGraphQL

public struct TierModel: Codable, Equatable, Hashable {
    let id: String
    let insuranceDisplayName: String
    let streetName: String
    let premium: MonetaryAmount
    let tiers: [TierLevel]
}

enum TierLevel: Codable, Equatable, Hashable {
    case mini
    case standard
    case max

    var displayName: String {
        switch self {
        case .mini:
            return "mini"
        case .standard:
            return "standard"
        case .max:
            return "max"
        }
    }
}
