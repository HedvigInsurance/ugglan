import Foundation

public protocol MovingFlowService {
    func getMoveItentData() async throws -> MovingFlowModel
}
