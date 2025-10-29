@preconcurrency import XCTest
import hCore

@testable import MoveFlow

@MainActor
final class HouseInformationInputModelTests: XCTestCase {
    weak var sut: MockMoveFlowService?

    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        try await Task.sleep(seconds: 0.0000001)
        XCTAssertNil(sut)
    }

    func testRemoveExtraBuildingSuccess() async {
        let model = HouseInformationInputModel()

        model.extraBuildings = [
            .init(id: "id1", type: "buidling type1", livingArea: 100, connectedToWater: false),
            .init(id: "id2", type: "buidling type2", livingArea: 120, connectedToWater: false),
            .init(id: "id3", type: "buidling type3", livingArea: 130, connectedToWater: false),
        ]

        assert(model.extraBuildings.count == 3)

        model.remove(
            extraBuilding:
                .init(id: "id3", type: "buidling type3", livingArea: 130, connectedToWater: false)
        )

        assert(model.extraBuildings.count == 2)
    }
}
