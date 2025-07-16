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
            maxHouseSquareMeters: nil
        )
    }

    public func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel {
        return MoveQuotesModel(homeQuotes: [], mtaQuotes: [], quotes: [], changeTierModel: nil)
    }

    public func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws {
    }
}
