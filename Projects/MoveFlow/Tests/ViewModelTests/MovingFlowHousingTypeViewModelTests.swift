@preconcurrency import XCTest
import hCore

@testable import MoveFlow

@MainActor
final class MovingFlowHousingTypeViewModelTests: XCTestCase {
    weak var sut: MockMoveFlowService?

    lazy var movingFlowModel: MoveQuotesModel = .init(
        homeQuotes: [],
        mtaQuotes: [],
        changeTierModel: nil
    )

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        XCTAssertNil(sut)
    }

    func testHousingTypeSuccess() async {
        let extraBuildings = [
            ExtraBuilding(
                id: "",
                type: ExtraBuildingType(type: "building type 1", displayName: "building display type"),
                livingArea: 20,
                connectedToWater: false
            )
        ]

        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            _ in
            self.movingFlowModel
        })
        sut = mockService

        let houseModel = HouseInformationInputModel()
        houseModel.extraBuildings = extraBuildings

        assert(houseModel.extraBuildings.count == extraBuildings.count)
        assert(houseModel.extraBuildings.first?.type == extraBuildings.first?.type)
    }
}
