import Foundation
import hCore

@MainActor
public class MoveFlowClientDemo: MoveFlowClient {
    public func sendMoveIntent() async throws -> MoveConfigurationModel {
        MoveConfigurationModel(
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

    public func requestMoveIntent(input _: RequestMoveIntentInput) async throws -> MoveQuotesModel {
        MoveQuotesModel(homeQuotes: [], mtaQuotes: [], changeTierModel: nil)
    }

    public func confirmMoveIntent(
        intentId _: String,
        currentHomeQuoteId _: String,
        removedAddons _: [String]
    ) async throws {}

    public func getMoveIntentCost(input: GetMoveIntentCostInput) async throws -> IntentCost {
        .init(totalGross: .sek(1000), totalNet: .sek(900))
    }
}
