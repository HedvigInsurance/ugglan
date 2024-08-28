import Presentation
import XCTest
import hCore

@testable import MoveFlow

final class HouseInformationInputModelTests: XCTestCase {
    weak var store: MoveFlowStore?
    weak var sut: MockMoveFlowService?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testRemoveExtraBuildingSuccess() async {
        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.setExtraBuildingType(with: "buidling type"))

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
