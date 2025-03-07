import Foundation

@MainActor
public class MoveFlowClientDemo: MoveFlowClient {
    public func sendMoveIntent() async throws -> MoveConfigurationModel {
        return MoveConfigurationModel(
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

    public func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel {
        return MoveQuotesModel(homeQuotes: [], mtaQuotes: [], changeTierModel: nil)
    }

    public func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws {
    }
}
