import MoveFlowCore
import Testing

@testable import MoveFlowUI

@MainActor
final class HouseInformationInputModelTests {
    @Test
    func removeExtraBuildingSuccess() {
        let model = HouseInformationInputModel()

        model.extraBuildings = [
            .init(
                id: "id1",
                type: ExtraBuildingType(type: "building type 1", displayName: "building display type"),
                livingArea: 100,
                connectedToWater: false
            ),
            .init(
                id: "id2",
                type: ExtraBuildingType(type: "building type 2", displayName: "building display type"),
                livingArea: 120,
                connectedToWater: false
            ),
            .init(
                id: "id3",
                type: ExtraBuildingType(type: "building type 3", displayName: "building display type"),
                livingArea: 130,
                connectedToWater: false
            ),
        ]

        #expect(model.extraBuildings.count == 3)

        model.remove(
            extraBuilding:
                .init(
                    id: "id3",
                    type: ExtraBuildingType(type: "building type 3", displayName: "building display type"),
                    livingArea: 130,
                    connectedToWater: false
                )
        )

        #expect(model.extraBuildings.count == 2)
    }

    @Test
    func asMoveHouseInformationInputCopiesFormValues() {
        let model = HouseInformationInputModel()
        model.yearOfConstruction = "1990"
        model.ancillaryArea = "25"
        model.bathrooms = 2
        model.isSubleted = true
        model.extraBuildings = [
            .init(
                id: "id1",
                type: ExtraBuildingType(type: "building type 1", displayName: "building display type"),
                livingArea: 100,
                connectedToWater: true
            )
        ]

        let input = model.asMoveHouseInformationInput

        #expect(input.yearOfConstruction == "1990")
        #expect(input.ancillaryArea == "25")
        #expect(input.bathrooms == 2)
        #expect(input.isSubleted)
        #expect(input.extraBuildings.map(\.id) == ["id1"])
    }
}
