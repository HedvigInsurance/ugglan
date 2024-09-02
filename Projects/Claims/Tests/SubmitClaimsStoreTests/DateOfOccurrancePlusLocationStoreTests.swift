import PresentableStore
import XCTest

@testable import Claims

final class DateOfOccurrancePlusLocationStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let dateOfOccurrancePlusLocationModel = ClaimsStepModelAction.DateOfOccurrencePlusLocationStepModels(
        dateOfOccurencePlusLocationModel: .init(id: "id"),
        dateOfOccurenceModel: .init(id: "id", maxDate: nil),
        locationModel: .init(id: "id", location: "HOME", options: [])
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

    func testDateOfOccurranceAndLocationSuccess() async {
        MockData.createMockSubmitClaimService(dateOfOccurrenceAndLocation: { context in
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
            .stepModelAction(action: .setDateOfOccurrencePlusLocation(model: dateOfOccurrancePlusLocationModel))
        )

        await store.sendAsync(.dateOfOccurrenceAndLocationRequest)

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(
            store.state.dateOfOccurrencePlusLocationStep
                == dateOfOccurrancePlusLocationModel.dateOfOccurencePlusLocationModel
        )
        assert(store.state.dateOfOccurenceStep == dateOfOccurrancePlusLocationModel.dateOfOccurenceModel)
        assert(store.state.locationStep == dateOfOccurrancePlusLocationModel.locationModel)
    }

    func testDateOfOccurranceAndLocationResponseFailure() async {
        MockData.createMockSubmitClaimService(dateOfOccurrenceAndLocation: { context in
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
            .stepModelAction(action: .setDateOfOccurrencePlusLocation(model: dateOfOccurrancePlusLocationModel))
        )

        await store.sendAsync(.dateOfOccurrenceAndLocationRequest)

        await waitUntil(description: "loading state") {
            store.loadingState[.postDateOfOccurrenceAndLocation] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testDateOfOccurranceAndLocationThrowFailure() async {
        MockData.createMockSubmitClaimService(dateOfOccurrenceAndLocation: { _ in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setDateOfOccurrencePlusLocation(model: dateOfOccurrancePlusLocationModel))
        )

        await store.sendAsync(.dateOfOccurrenceAndLocationRequest)

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postDateOfOccurrenceAndLocation] {
                return true
            } else {
                return false
            }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
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
