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

    var title: String {
        switch self {
        case .mini:
            return "Bas"
        case .standard:
            return "Standard"
        case .max:
            return "Max"
        }
    }

    var subTitle: String {
        switch self {
        case .mini:
            return "Vårt paket med grundläggande villkor."
        case .standard:
            return "Vårt mellanpaket med hög ersättning."
        case .max:
            return "Vårt största paket med högst ersättning."
        }
    }

    var premium: String {
        switch self {
        case .mini:
            return "199"
        case .standard:
            return "449"
        case .max:
            return "799"
        }
    }
}
