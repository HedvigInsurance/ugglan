public class MoveFlowDemoService: MoveFlowService {
    public func sendMoveIntent() async throws -> MovingFlowModel? {
        return nil
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel? {
        return nil
    }

    public func confirmMoveIntent(intentId: String) async throws {
    }
}
