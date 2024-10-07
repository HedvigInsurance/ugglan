import Foundation

public class MoveFlowClientDemo: MoveFlowClient {
    public func sendMoveIntent() async throws -> MovingFlowModel {
        return MovingFlowModel(
            id: "id",
            isApartmentAvailableforStudent: false,
            maxApartmentNumberCoInsured: nil,
            maxApartmentSquareMeters: nil,
            maxHouseNumberCoInsured: nil,
            maxHouseSquareMeters: nil,
            minMovingDate: Date().localDateString,
            maxMovingDate: "2025-06-01",
            suggestedNumberCoInsured: 2,
            currentHomeAddresses: [],
            quotes: [],
            faqs: [],
            extraBuildingTypes: []
        )
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel {
        return MovingFlowModel(
            id: "id",
            isApartmentAvailableforStudent: false,
            maxApartmentNumberCoInsured: nil,
            maxApartmentSquareMeters: nil,
            maxHouseNumberCoInsured: nil,
            maxHouseSquareMeters: nil,
            minMovingDate: Date().localDateString,
            maxMovingDate: "2025-06-01",
            suggestedNumberCoInsured: 2,
            currentHomeAddresses: [],
            quotes: [],
            faqs: [],
            extraBuildingTypes: []
        )
    }

    public func confirmMoveIntent(intentId: String, homeQuoteId: String?) async throws {
    }
}
