import hCore
import hGraphQL

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MoveIntentModel
    func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel,
        selectedAddressId: String
    ) async throws -> MoveIntentModel
    func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async throws
}
