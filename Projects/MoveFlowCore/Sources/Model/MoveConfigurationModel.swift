import Foundation
import hCore

public struct MoveConfigurationModel: Sendable {
    public let id: String
    public let currentHomeAddresses: [MoveAddress]
    public let extraBuildingTypes: [ExtraBuildingType]
    public let isApartmentAvailableforStudent: Bool
    public let maxApartmentNumberCoInsured: Int?
    public let maxApartmentSquareMeters: Int?
    public let maxHouseNumberCoInsured: Int?
    public let maxHouseSquareMeters: Int?

    public init(
        id: String,
        currentHomeAddresses: [MoveAddress],
        extraBuildingTypes: [ExtraBuildingType],
        isApartmentAvailableforStudent: Bool,
        maxApartmentNumberCoInsured: Int?,
        maxApartmentSquareMeters: Int?,
        maxHouseNumberCoInsured: Int?,
        maxHouseSquareMeters: Int?
    ) {
        self.id = id
        self.currentHomeAddresses = currentHomeAddresses
        self.extraBuildingTypes = extraBuildingTypes
        self.isApartmentAvailableforStudent = isApartmentAvailableforStudent
        self.maxApartmentNumberCoInsured = maxApartmentNumberCoInsured
        self.maxApartmentSquareMeters = maxApartmentSquareMeters
        self.maxHouseNumberCoInsured = maxHouseNumberCoInsured
        self.maxHouseSquareMeters = maxHouseSquareMeters
    }

    public func maxNumberOfCoinsuredFor(_ type: HousingType) -> Int {
        switch type {
        case .apartment, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }
}

public enum MovingFlowError: Error {
    case serverError(message: String)
    case missingDataError(message: String)
    case other

    public var title: String? {
        switch self {
        case .serverError:
            return L10n.generalContactUsTitle
        case .missingDataError:
            return nil
        case .other:
            return nil
        }
    }
}

extension MovingFlowError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .serverError(message): return message
        case let .missingDataError(message): return message
        case .other: return L10n.General.errorBody
        }
    }
}

public struct MoveAddress: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let displayTitle: String
    public let displaySubtitle: String?
    public let maxMovingDate: String
    public let minMovingDate: String
    public let suggestedNumberCoInsured: Int

    public init(
        id: String,
        displayTitle: String,
        displaySubtitle: String?,
        maxMovingDate: String,
        minMovingDate: String,
        suggestedNumberCoInsured: Int
    ) {
        self.id = id
        self.displayTitle = displayTitle
        self.displaySubtitle = displaySubtitle
        self.maxMovingDate = maxMovingDate
        self.minMovingDate = minMovingDate
        self.suggestedNumberCoInsured = suggestedNumberCoInsured
    }
}
