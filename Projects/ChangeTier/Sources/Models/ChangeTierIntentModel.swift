import hCore
import hCoreUI
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

    var perils: [Perils] {
        return [
            .init(id: "id1", title: "title", description: "description", info: nil, color: nil, covered: []),
            .init(id: "id2", title: "title2", description: "description", info: nil, color: nil, covered: []),
            .init(id: "id3", title: "title3", description: "description", info: nil, color: nil, covered: []),
        ]
    }

    var insurableLimits: [InsurableLimits] {
        return [
            .init(label: "label1", limit: "limit", description: "description"),
            .init(label: "label2", limit: "limit", description: "description"),
        ]
    }
}

public struct Deductible: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    let title: String
    let subTitle: String
    let label: String
}
