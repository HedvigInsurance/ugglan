import Testing

@testable import MoveFlow

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
}
