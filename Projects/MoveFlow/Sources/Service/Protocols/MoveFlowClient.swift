import hCore
import hCoreUI

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveConfigurationModel
    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel
    func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws
    func getMoveIntentCost(input: GetMoveIntentCostInput) async throws -> IntentCost
}

public struct RequestMoveIntentInput {
    public let intentId: String
    public let addressInputModel: AddressInputModel
    public let houseInformationInputModel: HouseInformationInputModel?
    public let selectedAddressId: String
}

public struct GetMoveIntentCostInput {
    public let intentId: String
    public let selectedHomeQuoteId: String
    public let selectedAddons: [String]
}
