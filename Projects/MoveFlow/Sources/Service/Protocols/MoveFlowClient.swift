import hCore
import hGraphQL

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveIntentModel
    func requestMoveIntent(input: RequestMoveIntentInput) async throws -> MoveRequestModel
    func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws
}

public struct RequestMoveIntentInput {
    let intentId: String
    let addressInputModel: AddressInputModel
    let houseInformationInputModel: HouseInformationInputModel?
    let selectedAddressId: String
}
