import Foundation

@MainActor
public class MoveFlowClientDemo: MoveFlowClient {
    public func sendMoveIntent() async throws -> MoveIntentModel {
        return MoveIntentModel(
            id: "id",
            currentHomeAddresses: [],
            extraBuildingTypes: [],
            isApartmentAvailableforStudent: false,
            maxApartmentNumberCoInsured: nil,
            maxApartmentSquareMeters: nil,
            maxHouseNumberCoInsured: nil,
            maxHouseSquareMeters: nil,
            maxMovingDate: "2025-06-01",
            minMovingDate: Date().localDateString,
            suggestedNumberCoInsured: 2
        )
    }

    public func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveRequestModel {
        return MoveRequestModel(homeQuotes: [], mtaQuotes: [], changeTierModel: nil)
    }

    public func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws {
    }
}
