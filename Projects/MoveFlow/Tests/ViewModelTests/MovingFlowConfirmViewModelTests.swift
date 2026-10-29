import Testing
import hCore

@testable import MoveFlow

extension MoveFlowDependencySuite {
    @MainActor
    final class MovingFlowConfirmViewModelTests {
        private weak var sut: MockMoveFlowService?

        @Test
        func confirmMoveIntentStoresNewContractId() async {
            // Scoped so mockService is released before expectServiceReleased() runs.
            do {
                let mockService = MockData.createMockMoveFlowService(
                    moveIntentConfirm: { _, _, _ in "new-contract-123" }
                )
                sut = mockService

                let model = MovingFlowConfirmViewModel()
                await model.confirmMoveIntent(intentId: "intent", currentHomeQuoteId: "quote", removedAddons: [])

                #expect(model.newContractId == "new-contract-123")
                #expect(model.viewState == .success)
                #expect(mockService.events.contains(.confirmMoveIntent))
            }

            await expectServiceReleased()
        }

        @Test
        func confirmMoveIntentFailureKeepsContractIdNil() async {
            do {
                let mockService = MockData.createMockMoveFlowService(
                    moveIntentConfirm: { _, _, _ in throw MovingFlowError.serverError(message: "failed") }
                )
                sut = mockService

                let model = MovingFlowConfirmViewModel()
                await model.confirmMoveIntent(intentId: "intent", currentHomeQuoteId: "quote", removedAddons: [])

                #expect(model.newContractId == nil)
                if case .error = model.viewState {
                    // expected
                } else {
                    Issue.record("Expected error view state")
                }
            }

            await expectServiceReleased()
        }

        // Not deinit: this has to suspend before it reads sut.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: MoveFlowClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }
    }
}
