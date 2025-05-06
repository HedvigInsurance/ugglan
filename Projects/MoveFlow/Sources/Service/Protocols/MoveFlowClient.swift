import hCore

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveConfigurationModel
    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveQuotesModel
    func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws
}

public struct RequestMoveIntentInput {
    public let intentId: String
    public let addressInputModel: AddressInputModel
    public let houseInformationInputModel: HouseInformationInputModel?
    public let selectedAddressId: String
}
