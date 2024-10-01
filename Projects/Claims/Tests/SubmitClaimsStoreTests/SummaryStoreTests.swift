import PresentableStore
import XCTest

@testable import Claims

final class SummaryStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let summaryModel: ClaimsStepModelAction.SummaryStepModels = .init(
        summaryStep: .init(
            id: "summary id",
            title: "title",
            shouldShowDateOfOccurence: true,
            shouldShowLocation: true,
            shouldShowSingleItem: true
        ),
        singleItemStepModel: .init(
            id: "id",
            availableItemBrandOptions: [],
            availableItemModelOptions: [],
            availableItemProblems: [],
            prefferedCurrency: "SEK",
            currencyCode: "SEK",
            defaultItemProblems: [],
            purchasePriceApplicable: true
        ),
        dateOfOccurenceModel: .init(id: "id", dateOfOccurence: "2024-08-20", maxDate: "2025-08-26"),
        locationModel: .init(id: "id", location: "HOME", options: []),
        audioRecordingModel: nil,
        fileUploadModel: nil
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

    func testSummarySuccess() async {
        MockData.createMockSubmitClaimService(summary: { context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setSuccessStep(model: .init(id: "id")))
            )
        }
        )

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setSummaryStep(model: summaryModel))
        )

        await store.sendAsync(.summaryRequest)

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.summaryStep == summaryModel.summaryStep)
    }

    func testSummaryResponseFailure() async {
        MockData.createMockSubmitClaimService(summary: { context in
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
            .stepModelAction(action: .setSummaryStep(model: summaryModel))
        )

        await store.sendAsync(.summaryRequest)

        await waitUntil(description: "loading state") {
            store.loadingState[.postSummary] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSummaryThrowFailure() async {
        MockData.createMockSubmitClaimService(summary: { context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setSummaryStep(model: summaryModel))
        )

        await store.sendAsync(.summaryRequest)
        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postSummary] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
