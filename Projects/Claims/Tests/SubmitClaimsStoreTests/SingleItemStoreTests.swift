import StoreContainer
import XCTest

@testable import Claims

final class SingleItemStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let singleItemModel: FlowClamSingleItemStepModel = .init(
        id: "id",
        availableItemBrandOptions: [],
        availableItemModelOptions: [],
        availableItemProblems: [],
        prefferedCurrency: nil,
        currencyCode: nil,
        defaultItemProblems: nil,
        purchasePriceApplicable: true
    )

    override func setUp() {
        super.setUp()
        hGlobalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testSingleItemSuccess() async {
        MockData.createMockSubmitClaimService(singleItem: { purchasePrice, context in
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
            .stepModelAction(action: .setSingleItem(model: singleItemModel))
        )

        await store.sendAsync(.singleItemRequest(purchasePrice: 6000))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.singleItemStep == singleItemModel)
    }

    func testSingleItemResponseFailure() async {
        MockData.createMockSubmitClaimService(singleItem: { purchasePrice, context in
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
            .stepModelAction(action: .setSingleItem(model: singleItemModel))
        )

        await store.sendAsync(.singleItemRequest(purchasePrice: 6000))

        await waitUntil(description: "loading state") {
            store.loadingState[.postSingleItem] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSingleItemThrowFailure() async {
        MockData.createMockSubmitClaimService(singleItem: { purchasePrice, context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setSingleItem(model: singleItemModel))
        )

        await store.sendAsync(.singleItemRequest(purchasePrice: 6000))

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postSingleItem] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
