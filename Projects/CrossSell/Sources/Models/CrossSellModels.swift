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
        case .home: return HCoreUIAsset.home.image
        case .car: return HCoreUIAsset.car.image
        case .accident: return HCoreUIAsset.bigPillowAccident.image
        case .pet: return HCoreUIAsset.dog.image
        case .unknown: return HCoreUIAsset.bigPillowHome.image
        }
    }

    public var displayText: String {
        switch type {
        case .home: return "Home"
        case .car: return "Car"
        case .accident: return "Accident"
        case .pet: return "Dog"
        case .unknown: return ""
        }
    }

    public var descriptionText: String {
        switch type {
        case .home: return "Best in class"
        case .car: return "No binding time"
        case .accident: return "Accident"
        case .pet: return "Unlimited FirstVet calls"
        case .unknown: return ""
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
