public protocol MoveFlowService {
    func sendMoveIntent() async throws -> MovingFlowModel
    func requestMoveIntent() async throws -> MovingFlowModel
}
