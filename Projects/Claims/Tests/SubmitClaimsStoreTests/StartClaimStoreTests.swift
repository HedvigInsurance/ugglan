import StoreContainer
import XCTest

@testable import Claims

final class StartClaimStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testStartClaimSuccess() async {
        MockData.createMockSubmitClaimService(start: { entrypointId, entrypointOptionId in
            .init(
                claimId: "claim id",
                context: "context",
                progress: 0.1,
                action: .stepModelAction(action: .setSuccessStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store

        await store.sendAsync(
            .startClaimRequest(entrypointId: "entrypoint id", entrypointOptionId: "entrypoint option id")
        )

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
    }

    func testStartClaimResponseFailure() async {
        MockData.createMockSubmitClaimService(start: { entrypointId, entrypointOptionId in
            .init(
                claimId: "claim id",
                context: "context",
                progress: 0.1,
                action: .stepModelAction(action: .setFailedStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store

        await store.sendAsync(
            .startClaimRequest(entrypointId: "entrypoint id", entrypointOptionId: "entrypoint option id")
        )

        await waitUntil(description: "loading state") {
            store.loadingState[.startClaim] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testStartClaimThrowFailure() async {
        MockData.createMockSubmitClaimService(start: { entrypointId, entrypointOptionId in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store

        await store.sendAsync(
            .startClaimRequest(entrypointId: "entrypoint id", entrypointOptionId: "entrypoint option id")
        )

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.startClaim] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
