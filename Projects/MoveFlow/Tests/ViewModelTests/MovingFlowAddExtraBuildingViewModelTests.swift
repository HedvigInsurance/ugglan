import XCTest
import hCore

@testable import MoveFlow

final class MovingFlowAddExtraBuildingViewModelTests: XCTestCase {
    let buildingType = ExtraBuildingType(type: "building type", displayName: "building display type")

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
