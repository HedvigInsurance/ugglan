import Presentation
import XCTest
import hCore

@testable import MoveFlow

final class MovingFlowHousingTypeViewModelTests: XCTestCase {
    weak var store: MoveFlowStore?
    weak var sut: MockMoveFlowService?

    let movingFlowModel: MovingFlowModel = .init(
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

        let model = MovingFlowHousingTypeViewModel()

        assert(model.selectedHousingType == "apartment")
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

        let model = MovingFlowHousingTypeViewModel()

        assert(model.selectedHousingType == "house")
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

        let model = MovingFlowHousingTypeViewModel()

        assert(model.selectedHousingType == "rental")
    }

    func testHousingTypeRentalFailure() async {
        let mockService = MockData.createMockMoveFlowService(moveIntentRequest: {
            intentId,
            addressInputModel,
            houseInformationInputModel in
            throw MovingFlowError.missingDataError(message: "error")
        })
        self.sut = mockService

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.setHousingType(with: .rental))

        let model = MovingFlowHousingTypeViewModel()

        assert(model.selectedHousingType != "rental")
    }
}
