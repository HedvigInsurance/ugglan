import Testing
import hCore

@testable import MoveFlow

extension MoveFlowDependencySuite {
    @MainActor
    final class MovingFlowHousingTypeViewModelTests {
        private weak var sut: MockMoveFlowService?

        lazy var movingFlowModel: MoveQuotesModel = .init(
            homeQuotes: [],
            mtaQuotes: [],
            changeTierModel: nil
        )

        init() {
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        }

        @Test
        func housingTypeSuccess() async {
            let extraBuildings = [
                ExtraBuilding(
                    id: "",
                    type: ExtraBuildingType(type: "building type 1", displayName: "building display type"),
                    livingArea: 20,
                    connectedToWater: false
                )
            ]

            // Scoped so mockService is released before expectServiceReleased() runs.
            do {
                let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
                    _ in
                    self.movingFlowModel
                })
                sut = mockService
            }

            let houseModel = HouseInformationInputModel()
            houseModel.extraBuildings = extraBuildings

            #expect(houseModel.extraBuildings.count == extraBuildings.count)
            #expect(houseModel.extraBuildings.first?.type == extraBuildings.first?.type)

            await expectServiceReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: MoveFlowClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
