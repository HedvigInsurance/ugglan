import Foundation

@MainActor
public class MoveFlowClientDemo: MoveFlowClient {
    public func sendMoveIntent() async throws -> MoveIntentModel {
        return MoveIntentModel(
            id: "id",
            currentHomeAddresses: [],
            extraBuildingTypes: [],
            homeQuotes: [
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
            isApartmentAvailableforStudent: false,
            maxApartmentNumberCoInsured: nil,
            maxApartmentSquareMeters: nil,
            maxHouseNumberCoInsured: nil,
            maxHouseSquareMeters: nil,
            maxMovingDate: "2025-06-01",
            minMovingDate: Date().localDateString,
            mtaQuotes: [],
            suggestedNumberCoInsured: 2,
            faqs: []
        )
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel,
        selectedAddressId: String
    ) async throws -> MoveIntentModel {
        return MoveIntentModel(
            id: "id",
            currentHomeAddresses: [],
            extraBuildingTypes: [],
            homeQuotes: [],
            isApartmentAvailableforStudent: false,
            maxApartmentNumberCoInsured: nil,
            maxApartmentSquareMeters: nil,
            maxHouseNumberCoInsured: nil,
            maxHouseSquareMeters: nil,
            maxMovingDate: "2025-06-01",
            minMovingDate: Date().localDateString,
            mtaQuotes: [],
            suggestedNumberCoInsured: 2,
            faqs: []
        )
    }

    public func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws {
    }
}
