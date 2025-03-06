import Foundation

@MainActor
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
            potentialHomeQuotes: [
                .init(
                    premium: .init(amount: "229", currency: "SEK"),
                    startDate: "2025-01-01",
                    displayName: "Quote1",
                    insurableLimits: [],
                    perils: [],
                    documents: [],
                    contractType: .seApartmentBrf,
                    id: "quoteId1",
                    displayItems: [],
                    exposureName: "exposure name",
                    addons: []
                )
            ],
            mtaQuotes: [],
            faqs: [],
            extraBuildingTypes: []
        )
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel,
        selectedAddressId: String
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
            potentialHomeQuotes: [],
            mtaQuotes: [],
            faqs: [],
            extraBuildingTypes: []
        )
    }

    public func confirmMoveIntent(intentId: String, homeQuoteId: String, removedAddons: [String]) async throws {
    }
}
