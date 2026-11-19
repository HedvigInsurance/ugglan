import Foundation
import hCore

public enum HousingType: String, CaseIterable, Codable, Equatable, Hashable, Sendable {
    case rental
    case apartment
    case house

    public var title: String {
        switch self {
        case .apartment:
            return L10n.changeAddressApartmentOwnLabel
        case .rental:
            return L10n.changeAddressApartmentRentLabel
        case .house:
            return L10n.changeAddressVillaLabel
        }
    }
}

public struct ExtraBuildingType: Sendable, Hashable {
    public let type: String
    public let displayName: String

    public init(type: String, displayName: String) {
        self.type = type
        self.displayName = displayName
    }
}

public struct ExtraBuilding: Identifiable, Sendable {
    public let id: String
    public let type: ExtraBuildingType
    public let livingArea: Int
    public let connectedToWater: Bool

    public init(id: String, type: ExtraBuildingType, livingArea: Int, connectedToWater: Bool) {
        self.id = id
        self.type = type
        self.livingArea = livingArea
        self.connectedToWater = connectedToWater
    }

    public var descriptionText: String {
        var elements: [String] = []
        elements.append("\(livingArea) \(L10n.changeAddressSizeSuffix)")
        if connectedToWater {
            elements.append(L10n.changeAddressExtraBuildingsWaterLabel)
        }
        return elements.displayName
    }
}
