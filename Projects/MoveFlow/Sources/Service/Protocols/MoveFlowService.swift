import hCore
import hGraphQL

public protocol MoveFlowService {
    func sendMoveIntent() async throws -> MovingFlowModel?
    func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel?
    func confirmMoveIntent(intentId: String) async throws
}
