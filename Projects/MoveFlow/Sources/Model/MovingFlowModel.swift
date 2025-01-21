import Addons
import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowModel: Codable, Equatable, Hashable, Sendable {
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
    let potentialHomeQuotes: [MovingFlowQuote]
    var homeQuote: MovingFlowQuote?
    let mtaQuotes: [MovingFlowQuote]
    let faqs: [FAQ]
    let extraBuildingTypes: [ExtraBuildingType]
    let changeTierModel: ChangeTierIntentModel?

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
        potentialHomeQuotes: [MovingFlowQuote],
        mtaQuotes: [MovingFlowQuote],
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
        self.mtaQuotes = mtaQuotes
        self.faqs = faqs
        self.extraBuildingTypes = extraBuildingTypes
        self.changeTierModel = nil
    }

    @MainActor
    var total: MonetaryAmount {
        let quoteAmount = mtaQuotes.reduce(0, { $0 + $1.premium.floatAmount }) + (homeQuote?.premium.floatAmount ?? 0)
        let addonAmount =
            mtaQuotes
            .compactMap({ $0.addons })
            .joined()
            .reduce(0, { $0 + $1.price.floatAmount })

        let addonHomeQuote = homeQuote?.addons.reduce(0, { $0 + $1.price.floatAmount }) ?? 0
        let totalAmount = quoteAmount + addonAmount + addonHomeQuote

        let currency = homeQuote?.premium.currency ?? mtaQuotes.first?.premium.currency ?? ""
        return MonetaryAmount(amount: totalAmount, currency: currency)
    }

    var movingDate: String {
        return homeQuote?.startDate ?? mtaQuotes.first?.startDate ?? ""
    }

    func maxNumberOfCoinsuredFor(_ type: HousingType) -> Int {
        switch type {
        case .apartment, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }

    var oldAddressCoverageDurationDays: Int? {
        currentHomeAddresses.first?.oldAddressCoverageDurationDays
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
