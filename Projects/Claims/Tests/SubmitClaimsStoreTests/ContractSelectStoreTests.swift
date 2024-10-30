import PresentableStore
import XCTest

@testable import Claims

final class ContractSelectStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let contractSelectModel: FlowClaimContractSelectStepModel = .init(
        availableContractOptions: [.init(displayName: "display name", id: "contract id")],
        selectedContractId: "contract id"
    )

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testContractSelectSuccess() async {
        MockData.createMockSubmitClaimService(contractSelect: { contractId, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setSuccessStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setContractSelectStep(model: contractSelectModel))
        )

        await store.sendAsync(.contractSelectRequest(contractId: "contract id"))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.contractStep == contractSelectModel)
    }

    func testContractSelectResponseFailure() async {
        MockData.createMockSubmitClaimService(contractSelect: { contractId, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setFailedStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setContractSelectStep(model: contractSelectModel))
        )

        await store.sendAsync(.contractSelectRequest(contractId: "contract id"))

        await waitUntil(description: "loading state") {
            store.loadingState[.postContractSelect] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testContractSelectThrowFailure() async throws {
        MockData.createMockSubmitClaimService(contractSelect: { contractId, context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setContractSelectStep(model: contractSelectModel))
        )

        await store.sendAsync(.contractSelectRequest(contractId: "contract id"))
        try await Task.sleep(nanoseconds: 5 * 100_000_000)
        var isError: Bool = false
        if case .error = store.loadingState[.postContractSelect] {
            isError = true
        }
        assert(isError)
        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
