import Foundation
import hCore

@testable import MoveFlow

@MainActor
struct MockData {
    static func createMockMoveFlowService(
        submitMoveIntent: @escaping SubmitMoveIntent = {
            .init(
                id: "id",
                currentHomeAddresses: [],
                extraBuildingTypes: [],
                isApartmentAvailableforStudent: true,
                maxApartmentNumberCoInsured: 6,
                maxApartmentSquareMeters: nil,
                maxHouseNumberCoInsured: nil,
                maxHouseSquareMeters: nil
            )
        },
        moveIntentRequest: @escaping MoveIntentRequest = { _ in
            .init(
                homeQuotes: [],
                mtaQuotes: [],
                changeTierModel: nil
            )
        },
        moveIntentConfirm: @escaping MoveIntentConfirm = { _, _, _ in
        },
        getMoveIntentCost: @escaping GetMoveIntentCost = { _ in
            .init(totalCost: .init(gross: .sek(1000), net: .sek(800)), quoteCosts: [])
        }
    ) -> MockMoveFlowService {
        let service = MockMoveFlowService(
            submitMoveIntent: submitMoveIntent,
            moveIntentRequest: moveIntentRequest,
            moveIntentConfirm: moveIntentConfirm,
            getMoveIntentCost: getMoveIntentCost
        )
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in service })
        return service
    }
}

typealias SubmitMoveIntent = () async throws -> MoveConfigurationModel
typealias MoveIntentRequest = (RequestMoveIntentInput) async throws -> MoveQuotesModel
typealias MoveIntentConfirm = (String, String, [String]) async throws -> Void
typealias GetMoveIntentCost = (GetMoveIntentCostInput) async throws -> hCore.IntentCost

@MainActor
class MockMoveFlowService: MoveFlowClient {
    var events = [Event]()

    var submitMoveIntent: SubmitMoveIntent
    var moveIntentRequest: MoveIntentRequest
    var moveIntentConfirm: MoveIntentConfirm
    var getMoveIntentCost: GetMoveIntentCost

    enum Event {
        case sendMoveIntent
        case requestMoveIntent
        case confirmMoveIntent
        case fetchMoveIntentCost
    }

    init(
        submitMoveIntent: @escaping SubmitMoveIntent,
        moveIntentRequest: @escaping MoveIntentRequest,
        moveIntentConfirm: @escaping MoveIntentConfirm,
        getMoveIntentCost: @escaping GetMoveIntentCost
    ) {
        self.submitMoveIntent = submitMoveIntent
        self.moveIntentRequest = moveIntentRequest
        self.moveIntentConfirm = moveIntentConfirm
        self.getMoveIntentCost = getMoveIntentCost
    }

    func sendMoveIntent() async throws -> MoveConfigurationModel {
        events.append(.sendMoveIntent)
        let data = try await submitMoveIntent()
        return data
    }

    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel {
        events.append(.requestMoveIntent)
        let data = try await moveIntentRequest(input)
        return data
    }

    func confirmMoveIntent(
        intentId: String,
        currentHomeQuoteId homeQuoteId: String,
        removedAddons: [String]
    ) async throws {
        events.append(.confirmMoveIntent)
        try await moveIntentConfirm(intentId, homeQuoteId, removedAddons)
    }

    func getMoveIntentCost(input: MoveFlow.GetMoveIntentCostInput) async throws -> hCore.IntentCost {
        events.append(.fetchMoveIntentCost)
        return try await self.getMoveIntentCost(input)
    }
}
