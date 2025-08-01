import hCore
import XCTest

@testable import MoveFlow

final class MovingFlowAddExtraBuildingViewModelTests: XCTestCase {
    let buildingType = "building type"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() async throws {}

    func testSetExtraBuildingSuccess() async {
        let model = MovingFlowAddExtraBuildingViewModel()
        model.livingArea = "80"
        model.buildingType = buildingType

        assert(model.isValid() == true)
    }

    func testIsNotValidSuccess() async {
        let model = MovingFlowAddExtraBuildingViewModel()
        model.buildingType = buildingType

        assert(model.isValid() == false)
    }
}
