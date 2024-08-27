import Presentation
import XCTest

@testable import Claims

final class FetchEntrypointGroupsStoreTests: XCTestCase {
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

    func testFetchEntrypointGroupsSuccess() async {
        let entrypointsGroupModel: [ClaimEntryPointGroupResponseModel] = [
            .init(
                id: "id",
                displayName: "display name",
                entrypoints: [
                    .init(
                        id: "entrypoint id",
                        displayName: "display name",
                        options: [
                            .init(
                                id: "entrypoint option id",
                                displayName: "display name"
                            )
                        ]
                    )
                ]
            )
        ]

        MockData.createMockFetchEntrypointsService(
            fetchEntrypoints: { entrypointsGroupModel }
        )

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(.fetchEntrypointGroups)

        assert(store.state.claimEntrypointGroups == entrypointsGroupModel)
    }

    func testFetchEntrypointGroupsThrowFailure() async {
        MockData.createMockFetchEntrypointsService(fetchEntrypoints: {
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(.fetchEntrypointGroups)

        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchClaimEntrypointGroups] != nil
        }
    }
}
