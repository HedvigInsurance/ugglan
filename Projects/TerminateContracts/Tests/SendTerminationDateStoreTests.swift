import Presentation
import XCTest

@testable import TerminateContracts

final class SendTerminationDateStoreTests: XCTestCase {
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

    func testSendTerminationDateSuccess() async {
        let terminationDate = "2024-09-25".localDateToDate

        let mockService = MockData.createMockTerminateContractsService(
            sendDate: { inputDateToString, context in
                .init(
                    context: context,
                    action: .stepModelAction(action: .setSuccessStep(model: .init(terminationDate: inputDateToString)))
                )
            }
        )

        let store = TerminationContractStore()
        self.store = store
        var newState = store.state
        newState.terminationDateStep = .init(
            id: "id",
            maxDate: "2025-08-08",
            minDate: "2024-08-08",
            date: "2024-10-25".localDateToDate
        )
        store.setState(newState)

        await store.sendAsync(.setTerminationDate(terminationDate: terminationDate ?? Date()))
        await store.sendAsync(.sendTerminationDate)

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.terminationDateStep?.date == terminationDate)
    }

    func testSendTerminationDateResponseFailure() async {
        let terminationDate = "2024-09-25".localDateToDate

        let mockService = MockData.createMockTerminateContractsService(
            sendDate: { inputDateToString, context in
                .init(context: context, action: .stepModelAction(action: .setFailedStep(model: .init(id: "id"))))
            }
        )

        let store = TerminationContractStore()
        self.store = store
        var newState = store.state
        newState.terminationDateStep = .init(
            id: "id",
            maxDate: "2025-08-08",
            minDate: "2024-08-08",
            date: "2024-10-25".localDateToDate
        )
        store.setState(newState)

        await store.sendAsync(.setTerminationDate(terminationDate: terminationDate ?? Date()))
        await store.sendAsync(.sendTerminationDate)

        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.sendTerminationDate] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSendTerminationDateThrowFailure() async {
        let terminationDate = "2024-09-25".localDateToDate

        let mockService = MockData.createMockTerminateContractsService(
            sendDate: { inputDateToString, context in
                throw TerminationError.error
            }
        )

        let store = TerminationContractStore()
        self.store = store
        var newState = store.state

        await store.sendAsync(.setTerminationDate(terminationDate: terminationDate ?? Date()))
        await store.sendAsync(.sendTerminationDate)

        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.sendTerminationDate] != nil
        }
        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}

/* TODO: MOVE LATER */
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
