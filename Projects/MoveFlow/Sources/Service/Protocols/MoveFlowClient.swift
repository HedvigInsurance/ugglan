import hCore
import hGraphQL

@MainActor
public protocol MoveFlowClient {
    func sendMoveIntent() async throws -> MovingFlowModel
    func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel
    func confirmMoveIntent(intentId: String, homeQuoteId: String, removedAddons: [String]) async throws
}
