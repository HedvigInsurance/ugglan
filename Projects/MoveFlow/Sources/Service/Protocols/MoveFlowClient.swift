import hCore

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveConfigurationModel
    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel
    func confirmMoveIntent(
        intentId: String,
        currentHomeQuoteId: String,
        removedAddons: [String]
    ) async throws
        -> String
    func getMoveIntentCost(input: GetMoveIntentCostInput) async throws -> IntentCost
}

public enum MovingFlowSource: Hashable, Identifiable {
    case insurance
    case termination

    public var id: Self { self }
}

public struct RequestMoveIntentInput {
    public let intentId: String
    public let addressInputModel: AddressInputModel
    public let houseInformationInputModel: HouseInformationInputModel?
    public let selectedAddressId: String
    public let source: MovingFlowSource
}

public struct GetMoveIntentCostInput {
    public let intentId: String
    public let selectedHomeQuoteId: String
    public let selectedAddons: [String]
}
