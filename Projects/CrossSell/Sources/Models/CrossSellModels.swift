import Foundation
import SwiftUI
import hCoreUI

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

    public static func hasBeenSeenKey(typeOfContract: String) -> String {
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

public enum CrossSellType: String, Codable, Hashable, Sendable {
    case car
    case home
    case accident
    case pet
    case unknown
}
