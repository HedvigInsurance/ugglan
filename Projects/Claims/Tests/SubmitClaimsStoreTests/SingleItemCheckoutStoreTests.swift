import PresentableStore
import XCTest

@testable import Claims

final class SingleItemCheckoutStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let singleItemCheckoutModel: FlowClaimSingleItemCheckoutStepModel = .init(
        id: "id",
        payoutMethods: [],
        compensation: .init(
            id: "id",
            deductible: .init(amount: "220", currency: "SEK"),
            payoutAmount: .init(amount: "220", currency: "SEK"),
            repairCompensation: nil,
            valueCompensation: nil
        ),
        singleItemModel: nil
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

    func testSingleItemCheckoutSuccess() async {
        MockData.createMockSubmitClaimService(singleItemCheckout: { context in
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
            .stepModelAction(action: .setSingleItemCheckoutStep(model: singleItemCheckoutModel))
        )

        await store.sendAsync(.singleItemCheckoutRequest)

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.singleItemCheckoutStep == singleItemCheckoutModel)
    }

    func testSingleItemCheckoutResponseFailure() async throws {
        MockData.createMockSubmitClaimService(singleItemCheckout: { context in
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
            .stepModelAction(action: .setSingleItemCheckoutStep(model: singleItemCheckoutModel))
        )

        await store.sendAsync(.singleItemCheckoutRequest)
        try await Task.sleep(nanoseconds: 100_000_000)
        assert(store.loadingState[.postSingleItemCheckout] == nil)
        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSingleItemCheckoutThrowFailure() async {
        MockData.createMockSubmitClaimService(singleItemCheckout: { context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setSingleItemCheckoutStep(model: singleItemCheckoutModel))
        )

        await store.sendAsync(.singleItemCheckoutRequest)

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postSingleItemCheckout] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
