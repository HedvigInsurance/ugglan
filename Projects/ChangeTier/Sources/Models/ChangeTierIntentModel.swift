import hGraphQL

public struct ChangeTierIntentModel: Codable, Equatable, Hashable {
    let id: String
    let insuranceDisplayName: String
    let streetName: String
    let currentPremium: MonetaryAmount
    let newPremium: MonetaryAmount
    let tiers: [Tier]
    let deductibles: [Deductible]
}

public enum Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String {
        /* TODO: CHANGE */
        return self.title ?? ""
    }

    case none
    case mini
    case standard
    case max

    var title: String? {
        switch self {
        case .mini:
            return "Bas"
        case .standard:
            return "Standard"
        case .max:
            return "Max"
        case .none:
            return nil
        }
    }

    var subTitle: String? {
        switch self {
        case .mini:
            return "Vårt paket med grundläggande villkor."
        case .standard:
            return "Vårt mellanpaket med hög ersättning."
        case .max:
            return "Vårt största paket med högst ersättning."
        case .none:
            return nil
        }
    }

    var premium: String? {
        switch self {
        case .mini:
            return "199"
        case .standard:
            return "449"
        case .max:
            return "799"
        case .none:
            return nil
        }
    }
}

public struct Deductible: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    let title: String
    let subTitle: String
    let label: String
}
