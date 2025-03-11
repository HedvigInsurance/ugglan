import Foundation
import SwiftUI
import hCoreUI
import hGraphQL

public struct CrossSell: Codable, Equatable, Hashable, Sendable {
    public var title: String
    public var description: String
    public var webActionURL: String?
    public var type: CrossSellType
    public var hasBeenSeen: Bool {
        didSet {
            UserDefaults.standard.set(hasBeenSeen, forKey: Self.hasBeenSeenKey(typeOfContract: type.rawValue))
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static func hasBeenSeenKey(typeOfContract: String) -> String {
        "CrossSell-hasBeenSeen-\(typeOfContract)"
    }

    public static func == (lhs: CrossSell, rhs: CrossSell) -> Bool {
        return lhs.type == rhs.type
    }

    public init(
        title: String,
        description: String,
        webActionURL: String? = nil,
        hasBeenSeen: Bool = false,
        type: CrossSellType
    ) {
        self.title = title
        self.description = description
        self.webActionURL = webActionURL
        self.hasBeenSeen = hasBeenSeen
        self.type = type
    }

    public init?(_ data: OctopusGraphQL.CrossSellFragment.CrossSell) {
        let type = data.type.crossSellType
        guard type != .unknown else { return nil }
        title = data.title
        description = data.description

        webActionURL = data.storeUrl
        self.type = type
        hasBeenSeen = UserDefaults.standard.bool(
            forKey: Self.hasBeenSeenKey(typeOfContract: type.rawValue)
        )
    }
}

extension CrossSell {
    public var image: UIImage {
        switch type {
        case .home: return HCoreUIAsset.bigPillowHome.image
        case .car: return HCoreUIAsset.bigPillowCar.image
        case .accident: return HCoreUIAsset.bigPillowAccident.image
        case .pet: return HCoreUIAsset.bigPillowPet.image
        case .unknown: return HCoreUIAsset.bigPillowHome.image
        }
    }
}

extension GraphQLEnum<OctopusGraphQL.CrossSellType> {
    var crossSellType: CrossSellType {
        switch self {
        case .case(let t):
            switch t {
            case .car:
                return .car
            case .home:
                return .home
            case .accident:
                return .accident
            case .pet:
                return .pet
            }
        case .unknown:
            return .unknown
        }
    }
}

public enum CrossSellType: String, Codable, Hashable, Sendable {
    case car
    case home
    case accident
    case pet
    case unknown
}
