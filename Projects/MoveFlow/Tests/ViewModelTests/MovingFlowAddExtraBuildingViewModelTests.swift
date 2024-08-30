import Presentation
import XCTest
import hCore

@testable import MoveFlow

final class MovingFlowAddExtraBuildingViewModelTests: XCTestCase {
    weak var store: MoveFlowStore?
    let buildingType = "building type"

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testSetExtraBuildingSuccess() async {
        let store = MoveFlowStore()
        self.store = store

        let model = MovingFlowAddExtraBuildingViewModel()
        model.livingArea = "80"

        await model.store.sendAsync(.setExtraBuildingType(with: buildingType))
        await waitUntil(description: "wait until building type is set") { [weak model] in
            model?.buildingType != nil
        }
        assert(model.isValid() == true)
    }

    func testIsNotValidSuccess() async {
        let store = MoveFlowStore()
        self.store = store

        let model = MovingFlowAddExtraBuildingViewModel()
        model.buildingType = buildingType

        assert(model.isValid() == false)
    }
}
