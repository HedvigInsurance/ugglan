import PresentableStore
import XCTest

@testable import Claims

final class PhoneNumberStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let phoneNumberModel: FlowClaimPhoneNumberStepModel = .init(id: "id", phoneNumber: "phone number")

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testPhoneNumberSuccess() async {
        MockData.createMockSubmitClaimService(update: { phoneNumber, context in
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
            .stepModelAction(action: .setPhoneNumber(model: phoneNumberModel))
        )

        await store.sendAsync(.phoneNumberRequest(phoneNumber: "phone number"))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.phoneNumberStep == phoneNumberModel)
    }

    func testPhoneNumberResponseFailure() async throws {
        MockData.createMockSubmitClaimService(update: { phoneNumber, context in
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
            .stepModelAction(action: .setPhoneNumber(model: phoneNumberModel))
        )

        await store.sendAsync(.phoneNumberRequest(phoneNumber: "phone number"))
        try await Task.sleep(nanoseconds: 300_000_000)
        assert(store.loadingState[.postPhoneNumber] == nil)
        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testPhoneNumberThrowFailure() async {
        MockData.createMockSubmitClaimService(update: { phoneNumber, context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setPhoneNumber(model: phoneNumberModel))
        )

        await store.sendAsync(.phoneNumberRequest(phoneNumber: "phone number"))
        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postPhoneNumber] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
