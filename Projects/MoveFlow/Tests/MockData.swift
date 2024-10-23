import Foundation
import hCore

@testable import MoveFlow

struct MockData {
    static func createMockMoveFlowService(
        submitMoveIntent: @escaping SubmitMoveIntent = {
            .init(
                id: "id",
                isApartmentAvailableforStudent: true,
                maxApartmentNumberCoInsured: 6,
                maxApartmentSquareMeters: nil,
                maxHouseNumberCoInsured: nil,
                maxHouseSquareMeters: nil,
                minMovingDate: Date().localDateString,
                maxMovingDate: "2025-09-08",
                suggestedNumberCoInsured: 2,
                currentHomeAddresses: [],
                potentialHomeQuotes: [],
                quotes: [],
                faqs: [],
                extraBuildingTypes: []
            )
        },
        moveIntentRequest: @escaping MoveIntentRequest = { intentId, addressInputModel, houseInformationInputModel in
            .init(
                id: intentId,
                isApartmentAvailableforStudent: true,
                maxApartmentNumberCoInsured: 6,
                maxApartmentSquareMeters: nil,
                maxHouseNumberCoInsured: nil,
                maxHouseSquareMeters: nil,
                minMovingDate: Date().localDateString,
                maxMovingDate: "2025-09-08",
                suggestedNumberCoInsured: 2,
                currentHomeAddresses: [],
                potentialHomeQuotes: [],
                quotes: [],
                faqs: [],
                extraBuildingTypes: []
            )
        },
        moveIntentConfirm: @escaping MoveIntentConfirm = { intentId, homeQuoteId in

        }
    ) -> MockMoveFlowService {
        let service = MockMoveFlowService(
            submitMoveIntent: submitMoveIntent,
            moveIntentRequest: moveIntentRequest,
            moveIntentConfirm: moveIntentConfirm
        )
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in service })
        return service
    }
}

typealias SubmitMoveIntent = () async throws -> MovingFlowModel
typealias MoveIntentRequest = (String, AddressInputModel, HouseInformationInputModel) async throws -> MovingFlowModel
typealias MoveIntentConfirm = (String, String?) async throws -> Void

class MockMoveFlowService: MoveFlowClient {
    var events = [Event]()

    var submitMoveIntent: SubmitMoveIntent
    var moveIntentRequest: MoveIntentRequest
    var moveIntentConfirm: MoveIntentConfirm

    enum Event {
        case sendMoveIntent
        case requestMoveIntent
        case confirmMoveIntent
    }

    init(
        submitMoveIntent: @escaping SubmitMoveIntent,
        moveIntentRequest: @escaping MoveIntentRequest,
        moveIntentConfirm: @escaping MoveIntentConfirm
    ) {
        self.submitMoveIntent = submitMoveIntent
        self.moveIntentRequest = moveIntentRequest
        self.moveIntentConfirm = moveIntentConfirm
    }

    func sendMoveIntent() async throws -> MovingFlowModel {
        events.append(.sendMoveIntent)
        let data = try await submitMoveIntent()
        return data
    }

    func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel {
        events.append(.requestMoveIntent)
        let data = try await moveIntentRequest(intentId, addressInputModel, houseInformationInputModel)
        return data
    }

    func confirmMoveIntent(intentId: String, homeQuoteId: String?) async throws {
        events.append(.confirmMoveIntent)
        try await moveIntentConfirm(intentId, homeQuoteId)
    }
}
