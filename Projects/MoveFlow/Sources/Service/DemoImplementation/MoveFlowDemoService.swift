import hGraphQL

public class MoveFlowDemoService: MoveFlowService {
    public func sendMoveIntent() async throws -> MovingFlowModel {
        return MovingFlowModel(
            from: OctopusGraphQL.MoveIntentFragment(_dataDict: .init(data: [:], fulfilledFragments: .init()))
        )
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel {
        return MovingFlowModel(
            from: OctopusGraphQL.MoveIntentFragment(_dataDict: .init(data: [:], fulfilledFragments: .init()))
        )
    }

    public func confirmMoveIntent(intentId: String) async throws {
    }
}
