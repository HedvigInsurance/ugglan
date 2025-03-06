import Addons
import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MoveIntentModel {
    let id: String
    let currentHomeAddresses: [MoveAddress]
    let extraBuildingTypes: [ExtraBuildingType]
    var currentHomeQuote: MovingFlowQuote?
    let homeQuotes: [MovingFlowQuote]
    let isApartmentAvailableforStudent: Bool
    let maxApartmentNumberCoInsured: Int?
    let maxApartmentSquareMeters: Int?
    let maxHouseNumberCoInsured: Int?
    let maxHouseSquareMeters: Int?
    let maxMovingDate: String
    let minMovingDate: String
    let mtaQuotes: [MovingFlowQuote]
    let suggestedNumberCoInsured: Int
    let changeTierModel: ChangeTierIntentModel?

    init(
        id: String,
        currentHomeAddresses: [MoveAddress],
        extraBuildingTypes: [ExtraBuildingType],
        homeQuotes: [MovingFlowQuote],
        isApartmentAvailableforStudent: Bool,
        maxApartmentNumberCoInsured: Int?,
        maxApartmentSquareMeters: Int?,
        maxHouseNumberCoInsured: Int?,
        maxHouseSquareMeters: Int?,
        maxMovingDate: String,
        minMovingDate: String,
        mtaQuotes: [MovingFlowQuote],
        suggestedNumberCoInsured: Int
    ) {
        self.id = id
        self.currentHomeAddresses = currentHomeAddresses
        self.extraBuildingTypes = extraBuildingTypes
        self.homeQuotes = homeQuotes
        self.isApartmentAvailableforStudent = isApartmentAvailableforStudent
        self.maxApartmentNumberCoInsured = maxApartmentNumberCoInsured
        self.maxApartmentSquareMeters = maxApartmentSquareMeters
        self.maxHouseNumberCoInsured = maxHouseNumberCoInsured
        self.maxHouseSquareMeters = maxHouseSquareMeters
        self.maxMovingDate = maxMovingDate
        self.minMovingDate = minMovingDate
        self.mtaQuotes = mtaQuotes
        self.suggestedNumberCoInsured = suggestedNumberCoInsured
        self.changeTierModel = nil
    }

    func maxNumberOfCoinsuredFor(_ type: HousingType) -> Int {
        switch type {
        case .apartment, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }

    var movingDate: String {
        return currentHomeQuote?.startDate ?? mtaQuotes.first?.startDate ?? ""
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

struct MovingFlowQuote: Codable, Equatable, Hashable {
    typealias KeyValue = (key: String, value: String)
    let premium: MonetaryAmount
    let startDate: String
    let displayName: String
    let insurableLimits: [InsurableLimits]
    let perils: [Perils]
    let documents: [InsuranceDocument]
    let contractType: TypeOfContract?
    let id: String
    let displayItems: [DisplayItem]
    let exposureName: String?
    let addons: [AddonDataModel]
}

struct InsuranceDocument: Codable, Equatable, Hashable {
    let displayName: String
    let url: String
}

struct DisplayItem: Codable, Equatable, Hashable {
    let displaySubtitle: String?
    let displayTitle: String
    let displayValue: String
}

struct AddonDataModel: Codable, Equatable, Hashable {
    let id: String
    let quoteInfo: InfoViewDataModel
    let displayItems: [DisplayItem]
    let coverageDisplayName: String
    let price: MonetaryAmount
    let addonVariant: AddonVariant
    let startDate: Date
    let removeDialogInfo: RemoveDialogInfo?
}

struct RemoveDialogInfo: Codable, Equatable, Hashable {
    let title: String
    let description: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
}
