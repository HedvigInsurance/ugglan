import StoreContainer
import XCTest

@testable import MoveFlow

final class MoveFlowStoreTests: XCTestCase {
    weak var store: MoveFlowStore?

    override func setUp() {
        super.setUp()
        hGlobalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testGetMoveIntentSuccess() async {
        let moveFlowModel = MovingFlowModel(
            id: "id",
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

        let mockService = MockData.createMockMoveFlowService(
            submitMoveIntent: { moveFlowModel }
        )

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.getMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.fetchMoveIntent] == nil
        }

        assert(store.state.movingFlowModel == moveFlowModel)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMoveIntent)
    }

    func testGetMoveIntentFailure() async {
        let mockService = MockData.createMockMoveFlowService(
            submitMoveIntent: { throw MovingFlowError.missingDataError(message: "error") }
        )

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.getMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.fetchMoveIntent] != nil
        }

        assert(store.state.movingFlowModel == nil)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMoveIntent)
    }

    func testRequestMoveIntentSuccess() async {
        let moveFlowModel = MovingFlowModel(
            id: "id",
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

        let mockService = MockData.createMockMoveFlowService(
            moveIntentRequest: { intentId, addressInputModel, houseInformationInputModel in moveFlowModel }
        )

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.requestMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.requestMoveIntent] == nil
        }

        assert(store.state.movingFlowModel == moveFlowModel)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .requestMoveIntent)
    }

    func testRequestMoveIntentFailure() async {
        let mockService = MockData.createMockMoveFlowService(
            moveIntentRequest: { _, _, _ in throw MovingFlowError.missingDataError(message: "error") }
        )

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.requestMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.requestMoveIntent] != nil
        }

        assert(store.state.movingFlowModel == nil)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .requestMoveIntent)
    }

    func testConfirmMoveIntentSuccess() async {
        let mockService = MockData.createMockMoveFlowService(
            moveIntentConfirm: { intentId in })

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.confirmMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.confirmMoveIntent] == nil
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .confirmMoveIntent)
    }

    func testConfirmMoveIntentFailure() async {
        let mockService = MockData.createMockMoveFlowService(
            moveIntentConfirm: { _ in throw MovingFlowError.missingDataError(message: "error") }
        )

        let store = MoveFlowStore()
        self.store = store
        await store.sendAsync(.confirmMoveIntent)

        await waitUntil(description: "loading state") {
            store.loadingState[.confirmMoveIntent] != nil
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .confirmMoveIntent)
    }
}

extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
