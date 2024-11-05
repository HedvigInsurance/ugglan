import PresentableStore
import XCTest
import hCore

@testable import MoveFlow

final class MovingFlowHousingTypeViewModelTests: XCTestCase {
    weak var sut: MockMoveFlowService?

    lazy var movingFlowModel: MovingFlowModel = .init(
        id: "intentId",
        isApartmentAvailableforStudent: true,
        maxApartmentNumberCoInsured: 6,
        maxApartmentSquareMeters: nil,
        maxHouseNumberCoInsured: nil,
        maxHouseSquareMeters: nil,
        minMovingDate: Date().localDateString,
        maxMovingDate: "2025-09-08",
        suggestedNumberCoInsured: 2,
        currentHomeAddresses: [],
        potentialHomeQuotes: [],
        quotes: [],
        faqs: [],
        extraBuildingTypes: []
    )

    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        XCTAssertNil(sut)
    }

    func testHousingTypeSuccess() async {
        let extraBuildings = [ExtraBuilding(id: "", type: "building tyoe", livingArea: 20, connectedToWater: false)]

        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            intentId,
            addressInputModel,
            houseInformationInputModel in
            self.movingFlowModel
        })
        self.sut = mockService

        let houseModel = HouseInformationInputModel()
        houseModel.extraBuildings = extraBuildings

        assert(houseModel.extraBuildings.count == extraBuildings.count)
        assert(houseModel.extraBuildings.first?.type == extraBuildings.first?.type)
    }
}
