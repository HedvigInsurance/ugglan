import Foundation
import hCore

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveConfigurationModel
    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel
    func confirmMoveIntent(
        intentId: String,
        currentHomeQuoteId: String,
        removedAddons: [String]
    ) async throws
        -> String
    func getMoveIntentCost(input: GetMoveIntentCostInput) async throws -> IntentCost
}

public enum MovingFlowSource: Hashable, Identifiable, Sendable {
    case insurance
    case termination

    public var id: Self { self }
}

public struct RequestMoveIntentInput: Sendable {
    public let intentId: String
    public let address: MoveAddressInput
    public let houseInformation: MoveHouseInformationInput?
    public let selectedAddressId: String
    public let source: MovingFlowSource

    public init(
        intentId: String,
        address: MoveAddressInput,
        houseInformation: MoveHouseInformationInput?,
        selectedAddressId: String,
        source: MovingFlowSource
    ) {
        self.intentId = intentId
        self.address = address
        self.houseInformation = houseInformation
        self.selectedAddressId = selectedAddressId
        self.source = source
    }
}

/// Snapshot of the new-address form, taken when the move intent is requested.
public struct MoveAddressInput: Sendable {
    public let address: String
    public let postalCode: String
    public let squareArea: String
    public let nbOfCoInsured: Int
    public let accessDate: Date?
    public let isStudent: Bool
    public let selectedHousingType: HousingType

    public init(
        address: String,
        postalCode: String,
        squareArea: String,
        nbOfCoInsured: Int,
        accessDate: Date?,
        isStudent: Bool,
        selectedHousingType: HousingType
    ) {
        self.address = address
        self.postalCode = postalCode
        self.squareArea = squareArea
        self.nbOfCoInsured = nbOfCoInsured
        self.accessDate = accessDate
        self.isStudent = isStudent
        self.selectedHousingType = selectedHousingType
    }
}

/// Snapshot of the house details form, taken when the move intent is requested.
public struct MoveHouseInformationInput: Sendable {
    public let yearOfConstruction: String
    public let ancillaryArea: String
    public let bathrooms: Int
    public let isSubleted: Bool
    public let extraBuildings: [ExtraBuilding]

    public init(
        yearOfConstruction: String,
        ancillaryArea: String,
        bathrooms: Int,
        isSubleted: Bool,
        extraBuildings: [ExtraBuilding]
    ) {
        self.yearOfConstruction = yearOfConstruction
        self.ancillaryArea = ancillaryArea
        self.bathrooms = bathrooms
        self.isSubleted = isSubleted
        self.extraBuildings = extraBuildings
    }
}

public struct GetMoveIntentCostInput: Sendable {
    public let intentId: String
    public let selectedHomeQuoteId: String
    public let selectedAddons: [String]

    public init(intentId: String, selectedHomeQuoteId: String, selectedAddons: [String]) {
        self.intentId = intentId
        self.selectedHomeQuoteId = selectedHomeQuoteId
        self.selectedAddons = selectedAddons
    }
}
