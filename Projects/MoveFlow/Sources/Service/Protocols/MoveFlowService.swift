import hGraphQL
import hCore

public protocol MoveFlowService {
    func sendMoveIntent() async throws -> MovingFlowModel?
    func requestMoveIntent(intentId: String, addressInputModel: AddressInputModel, houseInformationInputModel: HouseInformationInputModel) async throws -> MovingFlowModel?
    func confirmMoveIntent(intentId: String) async throws
}
