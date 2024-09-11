import PresentableStore
import XCTest

@testable import TerminateContracts

final class ConfirmDeleteStoreTests: XCTestCase {
    weak var store: TerminationContractStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testSendConfirmDeleteSuccess() async {
        let terminationDeleteStep: TerminationFlowDeletionNextModel = .init(id: "id")

        MockData.createMockTerminateContractsService(
            confirmDelete: { context in
                .init(
                    context: context,
                    action: .stepModelAction(action: .setSuccessStep(model: .init(terminationDate: nil)))
                )
            }
        )

        let store = TerminationContractStore()
        self.store = store
        await store.sendAsync(.stepModelAction(action: .setTerminationDeletion(model: terminationDeleteStep)))
        await store.sendAsync(.sendConfirmDelete)

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.terminationDeleteStep == terminationDeleteStep)
    }

    func testSendConfirmDeleteResponseFailure() async {
        let terminationDeleteStep: TerminationFlowDeletionNextModel = .init(id: "id")

        MockData.createMockTerminateContractsService(
            confirmDelete: { context in
                .init(context: context, action: .stepModelAction(action: .setFailedStep(model: .init(id: "id"))))
            }
        )

        let store = TerminationContractStore()
        self.store = store
        await store.sendAsync(.stepModelAction(action: .setTerminationDeletion(model: terminationDeleteStep)))
        await store.sendAsync(.sendConfirmDelete)

        await waitUntil(description: "loading state") {
            store.loadingState[.sendTerminationDate] != .loading
                && store.loadingState[.sendTerminationDate] == nil
        }
        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSendConfirmDeleteThrowFailure() async {
        let terminationDeleteStep: TerminationFlowDeletionNextModel = .init(id: "id")

        MockData.createMockTerminateContractsService(
            confirmDelete: { context in
                throw TerminationError.error
            }
        )

        let store = TerminationContractStore()
        self.store = store
        await store.sendAsync(.stepModelAction(action: .setTerminationDeletion(model: terminationDeleteStep)))
        await store.sendAsync(.sendConfirmDelete)

        await waitUntil(description: "loading state") {
            store.loadingState[.sendTerminationDate] != .loading
                && store.loadingState[.sendTerminationDate] != nil
        }
        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
