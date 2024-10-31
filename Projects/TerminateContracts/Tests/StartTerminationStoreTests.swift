import PresentableStore
import XCTest

@testable import TerminateContracts

final class StartTerminationStoreTests: XCTestCase {
    weak var store: TerminationContractStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") { [weak self] in
            self?.store == nil
        }
    }

    func testStartTerminationSuccess() async {
        let config: TerminationConfirmConfig = .init(
            contractId: "contractId",
            contractDisplayName: "contract display name",
            contractExposureName: "contract exposure name",
            activeFrom: nil
        )

        MockData.createMockTerminateContractsService(
            start: { contractId in
                .init(
                    context: "context",
                    action: .stepModelAction(action: .setSuccessStep(model: .init(terminationDate: nil)))
                )
            }
        )

        let store = TerminationContractStore()
        self.store = store
        await store.sendAsync(.startTermination(config: config))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.config == config)
    }

    func testStartTerminationResponseFailure() async throws {
        let config: TerminationConfirmConfig = .init(
            contractId: "contractId",
            contractDisplayName: "contract display name",
            contractExposureName: "contract exposure name",
            activeFrom: nil
        )

        MockData.createMockTerminateContractsService(
            start: { contractId in
                .init(context: "context", action: .stepModelAction(action: .setFailedStep(model: .init(id: "id"))))
            }
        )

        let store = TerminationContractStore()
        self.store = store

        await store.sendAsync(.startTermination(config: config))
        try await Task.sleep(nanoseconds: 300_000_000)
        assert(store.loadingState[.getInitialStep] == nil)
        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testStartTerminationThrowFailure() async throws {
        let config: TerminationConfirmConfig = .init(
            contractId: "contractId",
            contractDisplayName: "contract display name",
            contractExposureName: "contract exposure name",
            activeFrom: nil
        )

        MockData.createMockTerminateContractsService(
            start: { contractId in
                throw TerminationError.error
            }
        )

        let store = TerminationContractStore()
        self.store = store

        await store.sendAsync(.startTermination(config: config))
        try await Task.sleep(nanoseconds: 30_000_000)

        await waitUntil(description: "loading state") {
            store.loadingState[.getInitialStep] != nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
