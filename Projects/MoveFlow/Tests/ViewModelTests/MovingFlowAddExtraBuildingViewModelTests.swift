import Testing

@testable import MoveFlow

final class MovingFlowAddExtraBuildingViewModelTests {
    let buildingType = ExtraBuildingType(type: "building type", displayName: "building display type")

    @Test
    func setExtraBuildingSuccess() async {
        let model = MovingFlowAddExtraBuildingViewModel()
        model.livingArea = "80"
        model.buildingType = buildingType

        #expect(model.isValid() == true)
    }

    @Test
    func isNotValidSuccess() async {
        let model = MovingFlowAddExtraBuildingViewModel()
        model.buildingType = buildingType

        #expect(model.isValid() == false)
    }
}
