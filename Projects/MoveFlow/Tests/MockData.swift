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

typealias SubmitMoveIntent = () async throws -> MoveConfigurationModel
typealias MoveIntentRequest = (RequestMoveIntentInput) async throws -> MoveQuotesModel
typealias MoveIntentConfirm = (String, String, [String]) async throws -> Void

@MainActor
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
}
