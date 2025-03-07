import Addons
import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MoveConfigurationModel {
    let id: String
    let currentHomeAddresses: [MoveAddress]
    let extraBuildingTypes: [ExtraBuildingType]
    let isApartmentAvailableforStudent: Bool
    let maxApartmentNumberCoInsured: Int?
    let maxApartmentSquareMeters: Int?
    let maxHouseNumberCoInsured: Int?
    let maxHouseSquareMeters: Int?
    let maxMovingDate: String
    let minMovingDate: String
    let suggestedNumberCoInsured: Int

    init(
        id: String,
        currentHomeAddresses: [MoveAddress],
        extraBuildingTypes: [ExtraBuildingType],
        isApartmentAvailableforStudent: Bool,
        maxApartmentNumberCoInsured: Int?,
        maxApartmentSquareMeters: Int?,
        maxHouseNumberCoInsured: Int?,
        maxHouseSquareMeters: Int?,
        maxMovingDate: String,
        minMovingDate: String,
        suggestedNumberCoInsured: Int
    ) {
        self.id = id
        self.currentHomeAddresses = currentHomeAddresses
        self.extraBuildingTypes = extraBuildingTypes
        self.isApartmentAvailableforStudent = isApartmentAvailableforStudent
        self.maxApartmentNumberCoInsured = maxApartmentNumberCoInsured
        self.maxApartmentSquareMeters = maxApartmentSquareMeters
        self.maxHouseNumberCoInsured = maxHouseNumberCoInsured
        self.maxHouseSquareMeters = maxHouseSquareMeters
        self.maxMovingDate = maxMovingDate
        self.minMovingDate = minMovingDate
        self.suggestedNumberCoInsured = suggestedNumberCoInsured
    }

    func maxNumberOfCoinsuredFor(_ type: HousingType) -> Int {
        switch type {
        case .apartment, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }

}

enum MovingFlowError: Error {
    case serverError(message: String)
    case missingDataError(message: String)
    case other
}

extension MovingFlowError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .serverError(message): return message
        case let .missingDataError(message): return message
        case .other: return L10n.General.errorBody
        }
    }
}

public struct MoveAddress: Codable, Equatable, Hashable, Sendable {
    let id: String
    let displayName: String
    let exposureName: String
    let oldAddressCoverageDurationDays: Int?
}
