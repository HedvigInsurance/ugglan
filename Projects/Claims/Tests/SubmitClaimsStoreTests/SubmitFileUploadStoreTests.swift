import StoreContainer
import XCTest

@testable import Claims

final class SubmitFileUploadStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let fileUploadModel: FlowClaimFileUploadStepModel = .init(
        id: "id",
        title: "title",
        targetUploadUrl: "http://hedvig.com",
        uploads: []
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

    func testSubmitFileUploadSuccess() async {
        MockData.createMockSubmitClaimService(submitFile: { ids, context in
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
            .stepModelAction(action: .setFileUploadStep(model: fileUploadModel))
        )

        await store.sendAsync(.submitFileUpload(ids: ["id1, id2, id3"]))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.fileUploadStep == fileUploadModel)
    }

    func testSubmitFileUploadResponseFailure() async {
        MockData.createMockSubmitClaimService(submitFile: { ids, context in
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
            .stepModelAction(action: .setFileUploadStep(model: fileUploadModel))
        )

        await store.sendAsync(.submitFileUpload(ids: ["id1, id2, id3"]))

        await waitUntil(description: "loading state") {
            store.loadingState[.postUploadFiles] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSubmitFileUploadThrowFailure() async {
        MockData.createMockSubmitClaimService(submitFile: { ids, context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setFileUploadStep(model: fileUploadModel))
        )

        await store.sendAsync(.submitFileUpload(ids: ["id1, id2, id3"]))

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postUploadFiles] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
