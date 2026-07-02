import XCTest
import hCore

@testable import MoveFlow

@MainActor
final class MovingFlowConfirmViewModelTests: XCTestCase {
    weak var sut: MockMoveFlowService?

    override func setUp() async throws {
        try await super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: MoveFlowClient.self)
        XCTAssertNil(sut)
    }

    func testConfirmMoveIntentStoresNewContractId() async {
        let mockService = MockData.createMockMoveFlowService(
            moveIntentConfirm: { _, _, _ in "new-contract-123" }
        )
        sut = mockService

        let model = MovingFlowConfirmViewModel()
        await model.confirmMoveIntent(intentId: "intent", currentHomeQuoteId: "quote", removedAddons: [])

        assert(model.newContractId == "new-contract-123")
        assert(model.viewState == .success)
        assert(mockService.events.contains(.confirmMoveIntent))
    }

    func testConfirmMoveIntentFailureKeepsContractIdNil() async {
        let mockService = MockData.createMockMoveFlowService(
            moveIntentConfirm: { _, _, _ in throw MovingFlowError.serverError(message: "failed") }
        )
        sut = mockService

        let model = MovingFlowConfirmViewModel()
        await model.confirmMoveIntent(intentId: "intent", currentHomeQuoteId: "quote", removedAddons: [])

        assert(model.newContractId == nil)
        if case .error = model.viewState {
            // expected
        } else {
            XCTFail("Expected error view state")
        }
    }
}
