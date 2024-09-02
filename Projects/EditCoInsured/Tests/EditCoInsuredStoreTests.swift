import StoreContainer
import XCTest

@testable import EditCoInsured

final class EditCoInsuredStoreTests: XCTestCase {
    weak var store: EditCoInsuredStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testPerformCoInsuredChangesSuccess() async {
        let mockService = MockData.createMockEditCoInsuredService(
            sendMidtermChangeIntent: { commitId in }
        )

        let store = EditCoInsuredStore()
        self.store = store
        await store.sendAsync(.performCoInsuredChanges(commitId: "commitId"))

        await waitUntil(description: "loading state") {
            store.loadingState[.postCoInsured] == nil
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMidtermChangeIntentCommit)
    }

    func testPerformCoInsuredChangesFailure() async {
        let mockService = MockData.createMockEditCoInsuredService(
            sendMidtermChangeIntent: { commitId in
                throw EditCoInsuredError.otherError
            }
        )

        let store = EditCoInsuredStore()
        self.store = store
        await store.sendAsync(.performCoInsuredChanges(commitId: "commitId"))

        await waitUntil(description: "loading state") {
            store.loadingState[.postCoInsured] != nil
        }

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .sendMidtermChangeIntentCommit)
    }
}

extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
