import Foundation
import SwiftUI
import hCoreUI

public struct CrossSells: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id = UUID()
    public let recommended: CrossSell?
    public let others: [CrossSell]

    public init(recommended: CrossSell?, others: [CrossSell]) {
        self.recommended = recommended
        self.others = others
    }
}

public struct CrossSell: Codable, Equatable, Hashable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var webActionURL: String?
    public var type: CrossSellType
    public var bannerText: String?
    public var buttonText: String?
    public var discountText: String?
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
        id: String,
        title: String,
        description: String,
        webActionURL: String? = nil,
        type: CrossSellType,
        bannerText: String? = nil,
        buttonText: String? = nil,
        discountText: String? = nil,
        hasBeenSeen: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.webActionURL = webActionURL
        self.type = type
        self.bannerText = bannerText
        self.buttonText = buttonText
        self.discountText = discountText
        self.hasBeenSeen = hasBeenSeen
    }
}

@MainActor
extension CrossSell {
    public var image: Image {
        switch type {
        case .home: return hCoreUIAssets.bigPillowHome.view
        case .car: return hCoreUIAssets.bigPillowCar.view
        case .accident: return hCoreUIAssets.bigPillowAccident.view
        case .pet: return hCoreUIAssets.bigPillowPet.view
        case .apartmentBrf: return hCoreUIAssets.bigPillowHomeowner.view
        case .apartmentRent: return hCoreUIAssets.bigPillowRental.view
        case .unknown: return hCoreUIAssets.bigPillowHome.view
        case .petDog: return hCoreUIAssets.bigPillowDog.view
        case .petCat: return hCoreUIAssets.bigPillowCat.view
        case .house: return hCoreUIAssets.bigPillowVilla.view
        }
    }
}

public enum CrossSellType: String, Codable, Hashable, Sendable {
    case car
    case home
    case house
    case apartmentBrf
    case apartmentRent
    case accident
    case pet
    case petDog
    case petCat
    case unknown
}
