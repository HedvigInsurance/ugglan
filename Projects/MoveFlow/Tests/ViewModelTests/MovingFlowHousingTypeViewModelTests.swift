import Presentation
import XCTest
import hCore

@testable import MoveFlow

final class MovingFlowHousingTypeViewModelTests: XCTestCase {
    weak var store: MoveFlowStore?
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
        quotes: [],
        faqs: [],
        extraBuildingTypes: []
    )

    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
        XCTAssertNil(sut)
    }

    func testHousingTypeApartmentSuccess() async {
        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            intentId,
            addressInputModel,
            houseInformationInputModel in
            self.movingFlowModel
        })

        self.sut = mockService

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.setHousingType(with: .apartment))
        assert(store.state.selectedHousingType == .apartment)
    }

    func testHousingTypeHouseSuccess() async {
        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            intentId,
            addressInputModel,
            houseInformationInputModel in
            self.movingFlowModel
        })

        self.sut = mockService

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.setHousingType(with: .house))
        assert(store.state.selectedHousingType == .house)
    }

    func testHousingTypeRentalSuccess() async {
        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            intentId,
            addressInputModel,
            houseInformationInputModel in
            self.movingFlowModel
        })
        self.sut = mockService

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.setHousingType(with: .rental))
        assert(store.state.selectedHousingType == .rental)
    }
}
