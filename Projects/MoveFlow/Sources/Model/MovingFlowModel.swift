import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowModel: Codable, Equatable, Hashable {
    let id: String
    let isApartmentAvailableforStudent: Bool
    let maxApartmentNumberCoInsured: Int?
    let maxApartmentSquareMeters: Int?
    let maxHouseNumberCoInsured: Int?
    let maxHouseSquareMeters: Int?
    let minMovingDate: String
    let maxMovingDate: String
    let suggestedNumberCoInsured: Int
    let currentHomeAddresses: [MoveAddress]
    let potentialHomeQuotes: [Quote]
    var homeQuote: Quote?
    let quotes: [Quote]
    let faqs: [FAQ]
    let extraBuildingTypes: [ExtraBuildingType]
    let changeTier: ChangeTierIntentModel?

    init(
        id: String,
        isApartmentAvailableforStudent: Bool,
        maxApartmentNumberCoInsured: Int?,
        maxApartmentSquareMeters: Int?,
        maxHouseNumberCoInsured: Int?,
        maxHouseSquareMeters: Int?,
        minMovingDate: String,
        maxMovingDate: String,
        suggestedNumberCoInsured: Int,
        currentHomeAddresses: [MoveAddress],
        potentialHomeQuotes: [Quote],
        quotes: [Quote],
        faqs: [FAQ],
        extraBuildingTypes: [ExtraBuildingType]
    ) {
        self.id = id
        self.isApartmentAvailableforStudent = isApartmentAvailableforStudent
        self.maxApartmentNumberCoInsured = maxApartmentNumberCoInsured
        self.maxApartmentSquareMeters = maxApartmentSquareMeters
        self.maxHouseNumberCoInsured = maxHouseNumberCoInsured
        self.maxHouseSquareMeters = maxHouseSquareMeters
        self.minMovingDate = minMovingDate
        self.maxMovingDate = maxMovingDate
        self.suggestedNumberCoInsured = suggestedNumberCoInsured
        self.currentHomeAddresses = currentHomeAddresses
        self.potentialHomeQuotes = potentialHomeQuotes
        self.quotes = quotes
        self.faqs = faqs
        self.extraBuildingTypes = extraBuildingTypes
        self.changeTier = nil
    }

    var total: MonetaryAmount {
        let amount = quotes.reduce(0, { $0 + $1.premium.floatAmount }) + (homeQuote?.premium.floatAmount ?? 0)
        let currency = homeQuote?.premium.currency ?? quotes.first?.premium.currency ?? ""
        return MonetaryAmount(amount: amount, currency: currency)
    }

    var movingDate: String {
        return quotes.first?.startDate ?? ""
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

struct MoveAddress: Codable, Equatable, Hashable {
    let id: String
    let street: String
    let postalCode: String
    let city: String?
}

struct Quote: Codable, Equatable, Hashable {
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
